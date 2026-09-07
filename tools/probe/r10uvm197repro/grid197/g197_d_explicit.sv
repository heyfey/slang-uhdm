// r10uvm197 grid arm D — an EXPLICIT import of a typed string parameter, and a
// string parameter that is NEVER referenced, so the copy is materialized on
// structural grounds alone.
package dPkg;
  parameter string D_USED   = "used";
  parameter string D_UNUSED = "unusedstring";
  parameter string D_EMPTY  = "";
endpackage
module dMod;
  import dPkg::D_USED;
  import dPkg::D_UNUSED;
  import dPkg::D_EMPTY;
  initial $display(D_USED);
endmodule
