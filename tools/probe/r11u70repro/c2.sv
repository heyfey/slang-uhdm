package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module c2 import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{4'd1, 4'd2};
  assign o = A;
endmodule
