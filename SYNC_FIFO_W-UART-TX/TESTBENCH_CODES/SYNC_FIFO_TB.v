`timescale 1ns / 1ps

module SYNC_FIFO_TB;

         reg clk, rst, wr_enb, rd_enb ;
         reg[7:0] din ;
         wire [7:0] dout ;
         wire full, empty ;
         
         
         SYNC_FIFO DUT(clk, rst, wr_enb, rd_enb, din, dout, full, empty);
         
         
         always 
         #10 clk=~clk ;
         
         initial begin
         clk=1'b1; rst=1'b1; wr_enb=1'b0; rd_enb=1'b0; din=8'h00; 
         #3 rst=1'b0;
         end
         
         task prepare(input [7:0] byte);
         begin
         @(negedge clk)
         wr_enb<=1'b1;
         din<=byte;
         @(negedge clk)
         wr_enb<=1'b0;
         end
         endtask
         
         task read;
         begin
         @(negedge clk)
         rd_enb<=1'b1;
         @(negedge clk)
         rd_enb<=1'b0;
         end
         endtask
         
         initial 
                 begin
                 
                 $monitor("t=%0t wr_ptr=%0d rd_ptr=%0d count=%0d full=%b empty=%b dout=%h",
                 $time, DUT.wr_ptr, DUT.rd_ptr, DUT.count, full, empty, dout);
                 
                 //empty should be active here .
                 //now , feeding of bytes in the memory.
                 prepare(8'hca);
                 prepare(8'had);
                 prepare(8'hff);
                 prepare(8'hde);
                 prepare(8'h17);
                 prepare(8'h0a);
                 prepare(8'hbf);
                 prepare(8'h16);
                 //now the full is active.
                 
                 //corner case - write when full
                 prepare(8'hbc);   //nothing should happen;
                 
                 //corner case -- simulatneous rd and wr when full
                  @(negedge clk) begin
                 wr_enb<=1'b1;
                 din<=8'hbb;
                 rd_enb<=1'b1; end
                 @(negedge clk) begin
                 wr_enb<=1'b0; 
                 rd_enb<=1'b0;//write should be ignored , read should have happened.
                 if(dout==8'hca) $display("CORNER CASE READ&&WRITE&&FULL + WR&&FULL ARE EXAMINED SUCCESSFULLY"); end
                 
                 @(negedge clk) rst<=1'b1;
                 @(negedge clk) rst<=1'b0;
                 
                 
                 //empty should be active here .
                 //now , feeding of bytes in the memory.
                 prepare(8'hca);
                 prepare(8'had);
                 prepare(8'hff);
                 prepare(8'hde);
                 prepare(8'h17);
                 prepare(8'h0a);
                 prepare(8'hbf);
                 prepare(8'h16);
                 //now the full is active.
                 
                 
                 read;
                 if(dout==8'hca) $display("Correct extraction : %h" , dout);
                 
                 read;
                 if(dout==8'had) $display("Correct extraction : %h" , dout);
                 
                 read;
                 if(dout==8'hff) $display("Correct extraction : %h" , dout);
                 
                 read;
                 if(dout==8'hde) $display("Correct extraction : %h" , dout);
                 
                 read;
                 if(dout==8'h17) $display("Correct extraction : %h" , dout);
                 
                 read;
                 if(dout==8'h0a) $display("Correct extraction : %h" , dout);
                 
                 read;
                 if(dout==8'hbf) $display("Correct extraction : %h" , dout);
                 
                 read;
                 if(dout==8'h16) $display("Correct extraction : %h" , dout);
                 // now empty should be active 
                 
                 //corner case-- read when empty
                 read;   //nothing should happen.
                 
                 //corner case -- empty==1 and wr and read both high.
                 @(negedge clk) begin
                 wr_enb<=1'b1;
                 din<=8'hbb;
                 rd_enb<=1'b1; end
                 @(negedge clk) begin
                 wr_enb<=1'b0; 
                 rd_enb<=1'b0;
                 end //wr should be executed , read ignored.
                 //to check correctness--
                 read;
                 if(dout==8'hbb) $display("CORNER CASE READ&&WRITE&&EMPTY IS EXAMINED SUCCESSFULLY");
        
                 end
                 
                 initial
                 #1000 $finish;
                 
                 
endmodule
