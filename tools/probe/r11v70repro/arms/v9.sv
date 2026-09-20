package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module v9 import q::*; ();
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
endmodule
