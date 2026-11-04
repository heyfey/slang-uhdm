// § caFillPackedAggElabSharesDef301
module m(output logic [15:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } T;
  T [1:0] q;
  assign q = '1;
  assign o = q;
endmodule
