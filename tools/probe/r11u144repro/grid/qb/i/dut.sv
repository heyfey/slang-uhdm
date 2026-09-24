// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef enum logic [p::W-1:0] {A, B} e_t;
endpackage
module top(output logic o);
  q::e_t x;
  assign x = q::A;
  assign o = x[0];
endmodule
