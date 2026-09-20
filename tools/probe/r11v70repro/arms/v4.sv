package q;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } inr_t;
  typedef struct packed { inr_t a; logic [3:0] b; } out_t;
endpackage
module v4 import q::*; (output logic [11:0] o);
  localparam out_t A = out_t'{a: inr_t'{x: 4'd1, y: 4'd2}, b: 4'd3};
  assign o = A;
endmodule
