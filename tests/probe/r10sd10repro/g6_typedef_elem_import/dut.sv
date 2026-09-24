// THE DISCRIMINATOR CELL.  The element type is a PACKAGE TYPEDEF rather than a
// bare class name.  On the real corpus golden STAMPS 19 element-variable
// typespecs and ours agrees with it on the 8 that are key-matched, every one of
// them a named typedef; this cell is the one that has to hold, because a law
// reading "an import copy's element typespec carries no instance" would move it
// and a law reading "clone_tree duplicated it" must not.
package p6;
  typedef struct { int a6; int b6; } t6;
  t6 m6 [string];
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
