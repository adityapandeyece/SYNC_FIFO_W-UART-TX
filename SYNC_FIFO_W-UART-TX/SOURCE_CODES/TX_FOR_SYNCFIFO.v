//PARALLEL IN SERIAL OUT MODULE .
//idle → start_buffer → start → data → last_data_bit → parity → stop → idle
module TX_UART(clk,rst,enb_tx,empty,data_input,tx,busy,rd_enb);

         input clk , rst , enb_tx , empty ;    //observe how enb and clk signal should be synchronized for proper data transmission. 
                                             //for tx and brg modules .
         input [7:0] data_input ;               // 8-bit data input .
         output reg tx ;                     // declared reg , to be used in procedural blocks.
         output busy, rd_enb ;
         
         parameter idle = 3'b000;
         parameter start_buffer = 3'b001 ;
         parameter start = 3'b010;
         parameter data =3'b011;
         parameter last_data_bit=3'b100;
         parameter parity=3'b101;
         parameter stop =3'b110;
         
         reg [7:0] data_storage ;            // to store 8-bit data inputs .
         reg [2:0] curr_state ;                 //reg [1:0] curr_state = idle ; // initial curr_state = idle ; // works best for simulation 
                                                // --- in industry we always use a reset signal.
                                                // always initialize reset to 1 before applying stimulus in testbenches .
         reg [2:0] index ;                          // for indexing of data_bits . 
         reg count1;
    
         
         always @(posedge clk or posedge rst)    //use of asynchronous reset signal.
         begin
         
         if(rst) begin                          //reset is used to initialize non-wire outputs as well as internal variables.
                 tx<=1'b1;
                 
                 data_storage<=8'h00;
                 curr_state<=idle;
                 index<=3'b000;
                 count1<=1'b0;
                 end
          else 
                 begin
                 
                 case(curr_state)
                                
                                 
                                 idle: begin
                                       
                                       if(!empty) begin                        
                                                  
                                                  curr_state<=start_buffer;
                                                  index<=3'b000;
                                                 
                                                  end
                                       end
                                       
                                 start_buffer: begin                      
                                           
                                               if(enb_tx) begin
                                                          data_storage<=data_input;      //data_input idle me mat kro , kyunki tab hi rd_enb bhi active hua tha,
                                                          tx<=1'b0;                      //ek clock cycle to data generate krne me fifo ko bhi lagegi .
                                                          curr_state<=start;
                                                          count1<= ^data_input;             //1 if odd no of 1s are there , parity = even .
                                                          end
                                               end   
                                               
                                 start: begin
                                 
                                        if(enb_tx) begin
                                                   curr_state<=data;
                                                   tx<=data_storage[index];         //i.e., data_storage[0]
                                                   index<=index+1'b1;
                                                   end
                                 
                                        end  
                                        
                                 data: begin
                                       if(enb_tx) begin
                                                  tx<=data_storage[index];
                                       
                                                  if(index==3'b111) curr_state<=last_data_bit;
                                                  else index<=index+1'b1;
                                                 
                                                  end       
                                       end
                                       
                                 last_data_bit: begin
                                                if(enb_tx) begin
                                                           curr_state<=parity;
                                                           tx<=count1;
                                                           end
                                                end 
                                                
                                 parity: begin
                                         if(enb_tx) begin
                                                    curr_state<=stop;
                                                    tx<=1'b1;
                                                    end
                                         end                
                                                
                                 stop: begin
                                       
                                       if(enb_tx) begin
                                                  curr_state<=idle;
                                                  index<=3'b000;
                                                  data_storage<=8'h00;
                                                  end
                                       
                                       end  
                                       
                                 default: begin
                                          tx<=1'b1;
                 
                                          data_storage<=8'h00;
                                          curr_state<=idle;
                                          index<=3'b000;
                                          count1<=1'b0;
                                          end                     
                                                       
                 endcase
                 end        
                   
          end
          
          assign busy = (curr_state == idle || curr_state == start_buffer) ? 0 : 1;
          assign rd_enb = (empty==1'b0 && curr_state==idle)? 1:0;

endmodule
