// § tpEnumCopyAtTypedef184: two instances, one keeping the default type and one overriding it with a module enum; the enum used in the child body
module sub #(parameter type T = logic [2:0]) (input T si, output T so);
  T r;
  always_comb r = si;
  assign so = r;
endmodule
module top(input logic [2:0] a, output logic [2:0] b, output logic [2:0] c);
  typedef enum logic [2:0] {Q0 = 3'd2, Q1 = 3'd5} q_e;
  q_e x, y;
  assign x = q_e'(a);
  sub u0 (.si(a), .so(c));
  sub #(.T(q_e)) u1 (.si(x), .so(y));
  assign b = y;
endmodule
