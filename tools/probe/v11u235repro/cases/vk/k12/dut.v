// § vlogEnumBaseKwSpan235
module sub #(parameter W = 2) (output [W-1:0] o);
  typedef enum logic [W-1:0] {A, B} e_t;
  e_t x;
  assign o = x;
endmodule
module top(output [1:0] o, output [3:0] p);
  sub #(2) u0(o);
  sub #(.W(4)) u1(p);
endmodule
