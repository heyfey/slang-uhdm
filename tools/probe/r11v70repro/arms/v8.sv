package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
  typedef p2_t p2alias_t;
endpackage
module v8 import q::*; (output logic [7:0] o);
  localparam p2alias_t A = p2alias_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
