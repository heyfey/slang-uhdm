// § tpEnumCopyAtTypedef184: a module enum whose range reads an imported package parameter
package cfg;
  parameter int N = 4;
endpackage
module sub #(parameter type T = logic) (input T si, output T so);
  assign so = si;
endmodule
module top import cfg::*; (input logic [N-1:0] a, output logic [N-1:0] b);
  typedef enum logic [N-1:0] {P0 = 4'd5, P1 = 4'd7} p_e;
  p_e x, y;
  assign x = p_e'(a);
  sub #(.T(p_e)) u (.si(x), .so(y));
  assign b = y;
endmodule
