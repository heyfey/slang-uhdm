package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module sub5 import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
module v5 (output logic [7:0] o1, output logic [7:0] o2);
  sub5 u1(.o(o1));
  sub5 u2(.o(o2));
endmodule
