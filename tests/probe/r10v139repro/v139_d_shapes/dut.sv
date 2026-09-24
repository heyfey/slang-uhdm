// r10v139 arm D — SHAPES: multi-declarator lists, mixed lifetimes in one
// subroutine, declaration ORDER varied, mixed CASE, and the same declaration
// written three different ways.  Deliberately unlike the implementer's grid:
// the lifetimes appear in the order static / automatic / none here, the names
// are numerals-first, and two subroutines share a local name.
package Gasket139;
  class Ferrule139;
    function void multiDecl139;
      static int  n1, n2, n3;          // ONE declaration, three declarators
      automatic int m1, m2;
      int         p1, p2, p3, p4;
      string      s1 = "a", s2 = "b";  // multi + init, no keyword
      static string t1 = "a", t2 = "b";
      n1 = 1; m1 = 2; p1 = 3;
    endfunction
    function void orderVary139;
      automatic real   AA;
      int              bb;
      static bit [3:0] Cc;
      string           dD[$];
      static int       eE[];
      automatic int    fF[string];
      AA = 0.0; bb = 1; Cc = 2;
    endfunction
    // SAME local name in two subroutines, different spellings
    function void twinA139;
      static int shared139;
      shared139 = 1;
    endfunction
    function void twinB139;
      int shared139;
      shared139 = 2;
    endfunction
    // task-with-io + declarations after the io decl
    task ioThenDecl139;
      input int gg;
      static int hh;
      int        ii;
      automatic int jj;
      hh = gg; ii = gg; jj = gg;
    endtask
  endclass
endpackage
