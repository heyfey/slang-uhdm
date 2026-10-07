// § progDefKeepsLastInstProcs283
program prg #(parameter int W = 4) (input logic [W-1:0] a); int f; initial f = a + W; endprogram
module dut (output logic [31:0] o);
  logic [3:0] x; logic [7:0] y;
  prg #(4) u_1 (.a(x));
  prg #(.W(8)) u_2 (.a(y));
  assign o = 32'd0;
endmodule
