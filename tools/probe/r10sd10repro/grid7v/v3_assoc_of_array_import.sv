// VERIFIER CELL v3: assoc array whose ELEMENT is itself an unpacked array —
// exercises index AND elem, and depth 2.
package p9;
  class k9;
    int x9;
  endclass
  k9 m9 [string][2];
endpackage

package q9;
  import p9::*;
  class c9;
    int own9;
  endclass
endpackage

module top9;
  q9::c9 h9;
endmodule
