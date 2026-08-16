// VERIFIER CELL v1: does the ELEM arm ever fire?  A package FIXED-SIZE unpacked
// array of a class type, wildcard-imported into a package that declares a class.
package p7;
  class k7;
    int x7;
  endclass
  k7 m7 [4];
endpackage

package q7;
  import p7::*;
  class c7;
    int own7;
  endclass
endpackage

module top7;
  q7::c7 h7;
endmodule
