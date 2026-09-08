// r10uvm211 arm F — THE NON-REPAIRABLE STRUCT.  An array of a package struct
// whose members are all BUILT-IN types, so no member ever stood for a package
// scalar-typedef listing object and `repairable207` is false.  Nothing may
// move: BYTE-IDENTICAL on both binaries.
package p211a_f;
  typedef struct { int f_a211; int f_b211; } sf211;

  function automatic int ff211();
    sf211 lf211[$];
    return lf211.size();
  endfunction
endpackage

package p211b_f;
  import p211a_f::*;
  function automatic int gb211f();
    return ff211();
  endfunction
endpackage

module g211_f_nonrep;
  import p211b_f::*;
  int r211f;
  initial r211f = gb211f();
endmodule
