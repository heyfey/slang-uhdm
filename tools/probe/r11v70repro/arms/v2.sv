package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module v2 import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  localparam logic [3:0] SA = A.a;
  assign o = {A, SA};
endmodule
