// § pkgArrTdListing250 (control: an element typedef and two dims stay outside the law)
package p;
  typedef logic [3:0] n_t;
  typedef n_t e_t[4];
  typedef int t_t[2][3];
  typedef string s_t[$];
endpackage
module top;
  import p::*;
  e_t a; t_t b; s_t c;
endmodule
