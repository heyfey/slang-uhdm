// § tpCloneWholeLhsBare160
typedef struct packed { logic [3:0] x; logic [3:0] y; } pair_t;
module sub #(parameter type T = logic [7:0]) (input logic en, output T d_o, output T e_o);
  assign d_o = '{default: '0};
  assign e_o = en ? T'(8'h5A) : T'(0);
endmodule
module top (input logic en, output pair_t c, output pair_t e);
  sub #(.T(pair_t)) u(.en(en), .d_o(c), .e_o(e));
endmodule
