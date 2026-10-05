// § lawSStringTd243
// a parameter and a localparam of a string typedef, in the package and the module
package p;
  typedef string str_t;
  parameter str_t P = "pp";
  localparam str_t L = "ll";
endpackage
module top;
  import p::*;
  parameter str_t M = "mm";
  localparam str_t N = "nn";
  string s;
  initial s = {P, L, M, N};
endmodule
