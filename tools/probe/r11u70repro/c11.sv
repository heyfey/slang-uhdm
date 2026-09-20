package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module c11 import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  localparam p2_t B = p2_t'{a: 4'd3, b: 4'd4};
  assign o = A + B;
endmodule
