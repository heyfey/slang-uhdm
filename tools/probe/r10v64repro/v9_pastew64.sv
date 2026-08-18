// r10v64 ARM 9 — is the rawText-across-buffers misclassification PRE-EXISTING
// in the WIDTH arm (`bareW9`, landed before this pass)?  A token-pasted SIZED
// width literal.  MEASUREMENT ONLY.
`define W32 32
`define PASTE(n) `W32``'d``n
module leafV9 (input [3:0] a, input [3:0] b, output e);
  assign e = |a ^ |b;
endmodule
module midV9 (input [31:0] bus, output [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g_for
    leafV9 q0 (.a(bus[4 +: `PASTE(4)]), .b(bus[4 +: 32'd4]), .e(o[0]));
    leafV9 q1 (.a(bus[4 +: 4]),         .b(bus[i*4 +: 4]),   .e(o[1]));
  end
  assign o[7:2] = 6'b0;
endmodule
module topV9(input [31:0] bus, output [7:0] oa);
  midV9 u_a (bus, oa);
endmodule
