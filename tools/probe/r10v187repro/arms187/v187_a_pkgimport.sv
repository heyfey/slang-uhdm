// v187 arm A -- PACKAGE-TO-PACKAGE import re-listing of a scalar-typedef'd
// parameter, plus a bare use of a FOREIGN package's typedef inside a package.
package pa187;
  typedef int  a_i_t;
  typedef byte a_by_t;
  typedef bit  a_b1_t;
  parameter  a_i_t  A_P = 1;
  localparam a_by_t A_L = 2;
  parameter  a_b1_t A_B = 1'b1;
endpackage
package pb187;
  import pa187::*;
  export pa187::*;
  parameter a_i_t   B_BARE = 3;
  parameter int     B_USE  = A_P;
  parameter integer B_USE2 = A_L;
endpackage
package pc187;
  import pa187::a_i_t;
  import pa187::A_P;
  parameter a_i_t C_BARE = 4;
  parameter int   C_USE  = A_P;
endpackage
module ma187 ();
  import pb187::*;
  import pc187::*;
  localparam int MA = B_USE + C_USE + B_BARE + C_BARE;
endmodule
