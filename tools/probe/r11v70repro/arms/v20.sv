package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
  localparam int a = 7;
  localparam int b = 8;
endpackage
module v20 import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
