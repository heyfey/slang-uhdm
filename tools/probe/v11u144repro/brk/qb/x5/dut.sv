// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef logic [p::W-1:0] w_t;
  typedef enum logic [p::W/4-1:0] {A, B, C} e_t;
endpackage
module top(input q::w_t a, output logic o, output q::e_t e);
  assign o = a[0];
  assign e = q::B;
endmodule
