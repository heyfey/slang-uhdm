// § tpEnumCopyAtTypedef184: a positional override of a type parameter (two type parameters, the enum second), the child writing T procedurally only
module sub #(parameter type A = logic, parameter type T = logic) (input T si, output logic [3:0] so);
  T h;
  always_comb begin
    h = si;
    so = {2'b00, h};
  end
endmodule
module top (output logic [3:0] o);
  typedef enum logic [1:0] {P0, P1, P2} p_e;
  p_e v;
  sub #(logic [3:0], p_e) u (v, o);
endmodule
