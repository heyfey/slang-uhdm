// § pkgNetNamedTsDimEnd280
// an enum typedef element (a variable-road shape: abstains)
package pk;
  typedef enum logic [1:0] { A, B } e_t;
  e_t ev [0:1];
endpackage
module top(input pk::e_t i, output logic o);
  assign o = ^i;
endmodule
