// § tpWholeLhsInstantiatedOnly160v
typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
module sub #(parameter type T = logic [7:0], parameter int N = 0) (input T d_i, output T d_o);
  for (genvar i = 0; i < N; i++) begin : F
    assign d_o = d_i;
  end
  assign d_o.x = d_i.y;
  assign d_o.y = d_i.x;
endmodule
module top (input pair_t a, output pair_t c);
  sub #(.T(pair_t)) u(.d_i(a), .d_o(c));
endmodule
