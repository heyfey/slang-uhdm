// § caFillPackedAggElabSharesDef301
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module c(q);
  output s_t [1:0] q;
  assign q = '1;
endmodule
module m(output logic [15:0] o);
  c u(.q(o));
endmodule
