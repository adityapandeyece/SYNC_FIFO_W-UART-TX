module SYNC_FIFO(clk, rst, wr_enb, rd_enb, din, dout, full, empty);

         input clk, rst, wr_enb, rd_enb ;
         input [7:0] din ;
         output reg [7:0] dout ;
         output full, empty ;
         
         reg [7:0] memory[7:0] ;                       // memory[0] -> 8-bits=1-byte , memory[1] -> 8-bits=1-byte , and so on....
         reg [2:0] wr_ptr, rd_ptr ;
         reg [3:0] count ;
         
         integer i;
         
         always @(posedge clk or posedge rst) 
         begin
                     if(rst) begin                     //asynchronous reset 
                     
                             for(i=0;i<8;i=i+1) memory[i]<=8'd0;
                             dout<=8'h00;
                            
                                                       //there is no need to initialize memory -- as after reset -- wr_ptr, rd_ptr, count all become zero already.
                             wr_ptr<=3'b000;           //in such case value remaining in the memory  will itself get ignored and overwritten.
                             rd_ptr<=3'b000;           // but still you can use --- for(i=0; i<8; i=i+1)
                                                       //                                   mem[i] <= 8'd0;
                             count<=4'h0;
                             end
                             
                      else begin  
                                
                                if(wr_enb && !full) begin
                                                    memory[wr_ptr]<=din ;
                                                    
                                                    if(wr_ptr == 3'b111) wr_ptr<=3'b000;
                                                    else if (wr_ptr != 3'b111) wr_ptr<=wr_ptr+1'b1;
                                                    
                                                    end
                                                    
                                if(rd_enb && !empty) begin                                            //independent if's are used --as simultaneous rd and wr can occur.
                                                     dout<=memory[rd_ptr];
                                                     
                                                     if(rd_ptr == 3'b111) rd_ptr<=3'b000;
                                                     else if (rd_ptr != 3'b111) rd_ptr<=rd_ptr+1'b1;
                                                     
                                                     end
                                                     
                                  case ({wr_enb && !full, rd_enb && !empty})
                                                     2'b10: count <= count + 1; // write only      //we can't update count in above if-blocks , because if rd and
                                                     2'b01: count <= count - 1; // read only       //occur together -- then count would not be updated properly because
                                                     default: count <= count;   // both or none    //of non-blocking behavior --- two non-blocking assignment 
                                                                                                   //in same always block leads to dominance of the latest non-blocked value.
                                  endcase                    
                                                     
                                                                
                          end                              
         end
         
         assign full=(count==4'h8)?1:0 ;
         assign empty=(count==4'h0)?1:0 ;
         
endmodule
