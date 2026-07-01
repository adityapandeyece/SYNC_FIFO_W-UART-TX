`timescale 1ns / 1ps

module TOP_SYNCFIFO_TX_TB;

        reg clk,rst,wr_enb;
        reg [7:0] din ;
        wire enb_tx , full , empty , busy , tx ;
        
        reg [15:0] counter_tx ;
        
        

        TOP_SYNCFIFO_TX DUT(clk,rst,enb_tx,wr_enb,din,full,empty,busy,tx);

        assign enb_tx = (counter_tx==0)?1:0;
         
         
        always 
        #10 clk=~clk ;
        
        always @(posedge clk) begin
        if(counter_tx!=5207) counter_tx<=counter_tx+1'b1 ;
        else if(counter_tx==5207) counter_tx<=0; end
        
        initial begin
        counter_tx=0 ; clk=1'b1 ; rst=1'b1 ; wr_enb=1'b0 ; din=8'h00 ;
        #3 rst=1'b0 ; end
        
        task prepare(input [7:0] byte);
         begin
         @(negedge clk)
         wr_enb<=1'b1;
         din<=byte;
         @(negedge clk)
         wr_enb<=1'b0;
         end
         endtask
         
         
         initial 
         begin
         
         
         repeat(4) begin prepare($random); end
         

         
         #10000
         $finish;
         end

        

endmodule
