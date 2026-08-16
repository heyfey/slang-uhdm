// DEPTH: an associative array OF an associative array — the copy's typespec
// subtree is two levels deep, which is the recursion the patch performs.
package p6;
  int m6 [string][string];
endpackage

package q6;
  import p6::*;
  class c6;
    int own6;
  endclass
endpackage

module top6;
  q6::c6 h6;
endmodule
