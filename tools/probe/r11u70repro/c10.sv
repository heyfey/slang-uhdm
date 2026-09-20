package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module c10 import q::*; (output logic [7:0] o);
  wire [3:0] a;
  logic [3:0] b;
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
