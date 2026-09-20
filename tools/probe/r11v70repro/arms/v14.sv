package q;
  typedef struct { logic [3:0] a; logic [3:0] b; } u2_t;
  localparam u2_t UK = u2_t'{a: 4'd1, b: 4'd2};
  localparam logic [3:0] UA = UK.a;
endpackage
module v14 import q::*; (output logic [3:0] o);
  assign o = UA;
endmodule
