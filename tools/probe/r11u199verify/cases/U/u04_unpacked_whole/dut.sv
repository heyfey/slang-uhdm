// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [7:0] x, output logic [7:0] y [2], output logic [7:0] z [2]);
  assign y = c ? '{x, x} : '{default: '0};
  assign z[0] = c ? x : '0;
  assign z[1] = x;
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a [2], output logic [7:0] b [2], output logic [7:0] d [2], output logic [7:0] e [2]);
  m u_a (.c(c), .x(x), .y(a), .z(b));
  m u_b (.c(c), .x(x), .y(d), .z(e));
endmodule
