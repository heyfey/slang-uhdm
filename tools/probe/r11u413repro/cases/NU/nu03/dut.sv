// § unitTdCloneNoPrefixBit413
typedef bit i_t;
module sub #(parameter i_t N = 1) (output [7:0] o);
  assign o = N;
endmodule
module top (output [7:0] o);
  sub #(.N(1)) u (.o(o));
endmodule
