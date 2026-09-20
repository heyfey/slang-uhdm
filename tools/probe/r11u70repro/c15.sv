package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module sub #(parameter q::p2_t P = '{a:0, b:0}) (output logic [7:0] o);
  assign o = P;
endmodule
module c15 import q::*; (output logic [7:0] o);
  sub #(.P(p2_t'{a: 4'd1, b: 4'd2})) u(.o(o));
endmodule
