// § caLhsDefNetUnlessOpRhs139
module top(output logic o);
  typedef struct packed { logic a; } s_t;
  localparam s_t P = '{a: 1'b1};
  assign o = P.a;
endmodule
