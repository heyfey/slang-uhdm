// § caFillPackedAggElabSharesDef301
module m(output logic [7:0] o);
  typedef enum logic [3:0] { A, B } e_t;
  e_t [1:0] q;
  assign q = '1;
  assign o = q;
endmodule
