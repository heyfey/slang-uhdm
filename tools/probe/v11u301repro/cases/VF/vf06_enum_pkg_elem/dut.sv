// § caFillPackedAggElabSharesDef301
package pk;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module m(output logic [3:0] o);
  pk::e_t [1:0] q;
  assign q = '1;
  assign o = q;
endmodule
