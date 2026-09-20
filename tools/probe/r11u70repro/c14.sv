package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module c14 import q::*; (output logic [7:0] o);
  localparam int I = 4;
  localparam p2_t A = p2_t'{a: I[3:0], b: 4'd2};
  assign o = A;
endmodule
