// § progDefKeepsLastInstProcs283
program prg #(parameter int W = 4) (input logic [7:0] a); int f; initial begin f = a + W; end endprogram
module dut (output logic [31:0] o);
  logic [7:0] x, y;
  prg #(.W(2)) u_p (.a(x));
  prg #(.W(5)) u_q (.a(y));
  assign o = 32'd0;
endmodule
