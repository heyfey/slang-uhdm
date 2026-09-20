package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
  typedef enum logic [1:0] { a = 0, b = 1 } e_t;
endpackage
module v21 import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
