package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module v10 import q::*; (output logic [7:0] o);
  genvar a;
  logic [3:0] b;
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
  assign b = 4'd0;
endmodule
