// r10uvm210 grid arm G — THE R0 SHAPE, minimal.  A package class whose method
// declares a local of a TYPE-PARAMETER type: Surelog's CompileType falls through
// to its catch-all and mints an `unsupported_typespec` NAMED as written, and the
// DEF-view copy of that method body gets one whose `Instance` is the DEF-view
// package.  This is the object the SeqDriver head's compare actually crosses on.
package p210g;
  parameter G_LIT  = 5;
  parameter G_REF  = G_LIT;
  class cls210 #(type REQ = int);
    function void stop_sequences();
      REQ t;
      t = t;
    endfunction
  endclass
endpackage
module m210g;
  import p210g::*;
endmodule
