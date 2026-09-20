package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
  localparam p2_t PK = p2_t'{a: 4'd1, b: 4'd2};
endpackage
module c7 import q::*; (output logic [7:0] o);
  assign o = PK;
endmodule
