package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module v13 import q::*; (output logic [3:0] a, output logic [3:0] b);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign a = A.a;
  assign b = A.b;
endmodule
