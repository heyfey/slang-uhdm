// r10uvm220 arm a5 — the SAME body in a PACKAGE free function and in an
// in-body CLASS METHOD (the two holders § cloneForeachArrayRefUnresolved183 /
// § foreachFormalArrayTs9 already govern).  This arm is the FENCE calibration:
// nothing this pass writes may move a cell here.
package p220;

   class K220;
      int x;
   endclass

   int pvar220[4];

   function void f220(K220 a_dyn220[], input int a_fix220[4]);
      int loc220[5];
      foreach (a_dyn220[i0]) begin       // s01 FORMAL
      end
      foreach (a_fix220[i1]) begin       // s02 FORMAL, fixed-size int
      end
      foreach (loc220[i3]) begin         // s04 SUBROUTINE LOCAL
      end
      foreach (pvar220[i4]) begin        // s08 PACKAGE-LEVEL VARIABLE
      end
   endfunction

   class C220;
      int prop220[6];
      function void m220(K220 a_dyn220[]);
         int loc220[5];
         foreach (a_dyn220[i0]) begin    // s09 FORMAL in a CLASS METHOD
         end
         foreach (loc220[i3]) begin      // s10 LOCAL in a CLASS METHOD
         end
         foreach (prop220[i4]) begin     // s11 CLASS PROPERTY
         end
      endfunction
   endclass

endpackage

module top220k;
   initial begin
   end
endmodule
