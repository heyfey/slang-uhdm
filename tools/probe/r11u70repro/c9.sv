package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module c9 import q::*; (output p2_t o);
  assign o = p2_t'{a: 4'd1, b: 4'd2};
endmodule
