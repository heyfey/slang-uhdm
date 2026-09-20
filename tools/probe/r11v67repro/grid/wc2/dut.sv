// wc2 -- a $unit typedef over a SCOPED name, with a PACKED DIM written on it.
package pk;
  typedef logic [1:0] cv_t;
endpackage
typedef pk::cv_t [1:0] uqd_t;
module wc2;
  uqd_t  z03;
  wire uqd_t z04;
endmodule
