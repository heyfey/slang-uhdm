// § unitTdCloneNoPrefixBit413
typedef bit [7:0] i_t;
module sub #(parameter i_t N = 1, parameter i_t M = 2) (output [7:0] o);
  assign o = N + M;
endmodule
module top (output [7:0] o);
  sub #(.M(9)) u (.o(o));
endmodule
