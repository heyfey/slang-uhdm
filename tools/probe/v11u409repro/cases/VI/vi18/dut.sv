// § tdCloneNoPrefixAbstain409v
typedef int i_t;
module sub #(parameter i_t N = 2) (output [7:0] o);
  assign o = N;
endmodule
module top (output [7:0] o, output [7:0] o2);
  sub u (.o(o));
  sub #(7) v (.o(o2));
endmodule
