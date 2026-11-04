// § streamBraceInMacroBody246
`define REV(V) { << { V }}
`define NEST(A,B) { << 4 { { >> { A }}, B }}
module top(input logic [7:0] a, input logic [7:0] b, output logic [15:0] o, output logic [7:0] r);
  assign r = `REV(a);
  assign o = `NEST(a, b);
endmodule
