// § genScopeProcPsNamedByScope154
module rs #(parameter SYN = "TRUE", parameter SYNCPIPE = 2) (input clk, input nrst_in, output nrst_out);
   generate
      if(SYN == "TRUE")
	begin
	   reg [SYNCPIPE-1:0] sync_pipe;
	   always @ (posedge clk or negedge nrst_in)
	     if(!nrst_in)
	       sync_pipe[SYNCPIPE-1:0] <= 'b0;
	     else
	       sync_pipe[SYNCPIPE-1:0] <= {sync_pipe[SYNCPIPE-2:0],1'b1};
	   assign nrst_out = sync_pipe[SYNCPIPE-1];
	end
   endgenerate
endmodule
module top(input clk, input n, output o);
  rs r(clk, n, o);
endmodule
