// § unitTdCloneNoPrefixBit413
typedef bit [0:7] i_t;
module sub #(parameter i_t N = 1) (output [7:0] o);
  assign o = N;
endmodule
module top (output [7:0] o);
  sub u (.o(o));
endmodule
