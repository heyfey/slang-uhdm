// § tpCloneWholeLhsBare160
typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
typedef struct packed { logic [1:0] a; logic [5:0] b; } other_t;
module sub #(parameter type T = logic [7:0]) (input T d_i, output T d_o);
  assign d_o = d_i;
endmodule
module top (input pair_t a, input other_t b, output pair_t c, output other_t d);
  sub #(.T(pair_t)) u1(.d_i(a), .d_o(c));
  sub #(.T(other_t)) u2(.d_i(b), .d_o(d));
endmodule
