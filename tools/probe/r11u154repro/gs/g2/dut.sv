// § genProcFoldTsKeepsScope154
module ds #(parameter SYN = "TRUE", parameter SYNCPIPE = 2) (input clk, input nreset, input din, output dout);
   generate
      if(SYN == "TRUE")	begin
	 reg [SYNCPIPE:0] sync_pipe;
	 always @ (posedge clk or negedge nreset)
	   if(!nreset)
	     sync_pipe[SYNCPIPE:0] <= 'b0;
	   else
	     sync_pipe[SYNCPIPE:0] <= {sync_pipe[SYNCPIPE-1:0],din};
	 assign dout = sync_pipe[SYNCPIPE];
      end
   endgenerate
endmodule
module top(input clk, input n, input d, output [1:0] o);
  ds w[1:0] (clk, n, d, o);
endmodule
