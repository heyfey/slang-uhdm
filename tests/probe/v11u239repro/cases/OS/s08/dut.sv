// § genConnOpSelIdxScope239
// the index a wildcard-imported package parameter; a ternary and a unary actual
package p;
  parameter int SEL = 2;
endpackage
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module top import p::*; (input logic r, input logic [3:0] v, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_b
    sub u_s (.a_i(r & v[SEL]), .b_i(r ? v[i] : ~v[i]), .o(o[i]));
  end
endmodule
