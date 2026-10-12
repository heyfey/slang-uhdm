// § caFillPackedAggElabSharesDef301
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
endpackage
module m(output logic [15:0] o);
  pk::s_t [1:0] q;
  assign q = '1;
  assign o = q;
endmodule
