module TOP_SYNCFIFO_TX(clk,rst,enb_tx,wr_enb,din,full,empty,busy,tx);

            input clk, rst, wr_enb, enb_tx ;
            input [7:0] din ;
            output full, empty, busy, tx ;
            
            wire rd_enb ;
            wire [7:0] mid_dout ;
            
            TX_UART TX(clk,rst,enb_tx,empty,mid_dout,tx,busy,rd_enb);
            SYNC_FIFO FIFO(clk, rst, wr_enb, rd_enb, din, mid_dout, full, empty);


endmodule
