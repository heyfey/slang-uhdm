package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module c8 import q::*; (output logic [7:0] o);
  p2_t v;
  initial v = p2_t'{a: 4'd1, b: 4'd2};
  assign o = v;
endmodule
