// § unitTdCloneNoPrefixBit413
typedef bit [15:0] w_t;
module sub #(parameter w_t N = 16'hff) (output [15:0] o);
  assign o = N;
endmodule
module top (output [15:0] o);
  sub #(.N(16'h1234)) u (.o(o));
endmodule
