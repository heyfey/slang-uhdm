// § caFillPackedAggElabSharesDef301
module m(output logic [15:0] o);
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  u_t [1:0] q;
  assign q = '1;
  assign o = q;
endmodule
