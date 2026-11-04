// § tdCloneNoPrefixAbstain409v
typedef int i_t;
module sub #(parameter i_t N = 2) (output [7:0] o);
  assign o = N;
endmodule
module top (output [7:0] o);
  sub #(.N(5)) u (.o(o));
endmodule
