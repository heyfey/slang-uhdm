package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
  localparam p2_t PK = p2_t'{a: 4'd1, b: 4'd2};
  localparam logic [3:0] AA = PK.a;
endpackage
module v1 import q::*; (output logic [7:0] o, output logic [3:0] o2);
  assign o = PK;
  assign o2 = AA;
endmodule
