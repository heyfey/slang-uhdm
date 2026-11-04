// § tpEnumCopyAtTypedef184: a type parameter overridden through a defparam-style value parameter is not legal, so the override is a named type override beside a defparam of a value parameter in the same instance
module sub #(parameter type T = logic, parameter int N = 1) (input T si, output logic [7:0] so);
  T q;
  always_comb q = si;
  assign so = 8'(q) + 8'(N);
endmodule
module top (output logic [7:0] o);
  typedef enum logic [2:0] {K0, K1 = 3'd5} k_e;
  k_e p;
  sub #(.T(k_e)) u (.si(p), .so(o));
  defparam u.N = 3;
endmodule
