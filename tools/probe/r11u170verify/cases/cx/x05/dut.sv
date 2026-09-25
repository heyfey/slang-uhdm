// § genCaLhsEnumConstClone158 § tpCloneWholeLhsBare160
typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
module sub #(parameter type T = logic [7:0]) (input T d_i, output T d_o, output logic [7:0] m);
  typedef enum int { K_LO = 2, K_HI = 5 } k_t;
  if (1) begin : G
    assign d_o = d_i;
    assign m[K_HI:K_LO] = 4'hF;
  end
endmodule
module top (input pair_t a, output pair_t c, output logic [7:0] m);
  sub #(.T(pair_t)) u(.d_i(a), .d_o(c), .m(m));
endmodule
