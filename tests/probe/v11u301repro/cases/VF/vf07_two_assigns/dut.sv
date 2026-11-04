// § caFillPackedAggElabSharesDef301
module m(output logic [31:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t [1:0] q, r;
  assign q = '1;
  assign r = '0;
  assign o = {q, r};
endmodule
