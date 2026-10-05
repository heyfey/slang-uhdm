// § pkgArrTdListing250
package p;
  typedef bit b1_t[1];
  typedef int r_t[1:3];
  typedef byte d_t[7:0];
  typedef logic [0:3] e_t[16];
  typedef shortint unsigned f_t[2];
  typedef bit [1:0][3:0] g_t[3];
endpackage
module top;
  import p::*;
  b1_t a; r_t b; d_t c; e_t d; f_t e; g_t f;
endmodule
