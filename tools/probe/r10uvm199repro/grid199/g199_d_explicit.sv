// r10uvm199 grid arm D — EXPLICIT import items, one of them never referenced,
// so the copy is materialized on structural grounds alone.  `D_UDEC` is the
// CONTROL row: an untyped PLAIN-DECIMAL parameter whose copy golden DOES give
// an `int_typespec` — the law must not touch it.
package dPkg;
  parameter D_UHEX   = 'h1a;
  parameter D_UNUSED = 'b1010;
  parameter D_UDEC   = 42;
endpackage
module dMod;
  import dPkg::D_UHEX;
  import dPkg::D_UNUSED;
  import dPkg::D_UDEC;
  initial $display(D_UHEX);
endmodule
