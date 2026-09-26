// § tfArgQualOutsideWriter176
`define MKF(nm, ty) function automatic logic nm(ty x); return x == q::B; endfunction
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top (input q::e_t s, output logic o);
  `MKF(f, q::e_t)
  assign o = f(s);
endmodule
