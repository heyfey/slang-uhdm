// § unitTdCloneNoPrefixBit413
typedef bit [7:0] i_t;
module sub #(parameter i_t N = 1) (output [7:0] o);
  assign o = N;
endmodule
module mid (output [7:0] o);
  sub #(.N(3)) u (.o(o));
endmodule
module top (output [7:0] o);
  mid m (.o(o));
endmodule
