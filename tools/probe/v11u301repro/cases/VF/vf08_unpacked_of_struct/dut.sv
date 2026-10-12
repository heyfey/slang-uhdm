// § caFillPackedAggElabSharesDef301
module m(output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t q [2];
  assign q = '{default: '1};
  assign o = q[0];
endmodule
