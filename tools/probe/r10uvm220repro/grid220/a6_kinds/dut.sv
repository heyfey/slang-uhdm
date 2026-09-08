// r10uvm220 arm a6 — the FENCE arm, inside an UNINSTANTIATED interface.
// Every shape whose typespec Surelog decides BEFORE `lateTypedefBinding` ever
// runs, so that skipping that pass cannot be what answers it:
//   s12  the iterated name IS also a TYPE name (the placeholder tail's first
//        lookup succeeds and no placeholder is ever minted)
//   s13  a DOTTED iterated reference (`h.q[i]`) — compileVariable's hier_path
//        arm returns before any typespec is built at all
//   s14  a `::`-scoped iterated reference — § foreachScopedArrayWrittenClassVar33
//   s15  an iterated PARAMETER of a package, reached through `::`
//   s16  a typedef'd array type used as a formal
//   s17  the same formal iterated TWICE (the sharing-by-identity question)
package q220;
   parameter int QP220[3] = '{1,2,3};
   typedef int arr220_t[4];
endpackage

class K220;
   int x;
endclass

class H220;
   int q220[5];
endclass

interface if220f();
   import q220::*;

   typedef int t220[4];          // s12: a TYPE whose name a formal will shadow
   H220 h220;

   function void f220(K220 a_dyn220[], t220 a_td220, input int t220_x);
      foreach (a_dyn220[i0]) begin   // s17a the SAME formal, first foreach
      end
      foreach (a_dyn220[i1]) begin   // s17b the SAME formal, second foreach
      end
      foreach (a_td220[i2]) begin    // s16 a formal of a TYPEDEF'd array type
      end
      foreach (h220.q220[i3]) begin  // s13 a DOTTED iterated reference
      end
      foreach (q220::QP220[i4]) begin // s15 a `::`-scoped PACKAGE PARAMETER
      end
   endfunction

   function void g220(input int t220[4]);
      foreach (t220[i5]) begin       // s12 the formal SHADOWS a typedef name
      end
   endfunction

endinterface

module top220f;
   initial begin
   end
endmodule
