package q;
  typedef struct { logic [3:0] a; logic [3:0] b; } u2_t;
endpackage
module c3 import q::*; (output logic [3:0] o);
  localparam u2_t A = u2_t'{a: 4'd1, b: 4'd2};
  assign o = A.a;
endmodule
