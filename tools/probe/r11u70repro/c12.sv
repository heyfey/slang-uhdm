package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module c12 import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{default: 4'd1};
  assign o = A;
endmodule
