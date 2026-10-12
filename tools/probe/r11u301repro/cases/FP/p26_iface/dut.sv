// § caFillPackedAggElabSharesDef301
interface ifc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t [1:0] q;
  assign q = '1;
endinterface
module m(output logic [15:0] o);
  ifc u();
  assign o = u.q;
endmodule
