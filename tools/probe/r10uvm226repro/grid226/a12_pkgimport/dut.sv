// arm a12: the MUST-STAY floor.  Every named boundary family that touches an
// interface DEFINITION, in one file, so a process list appearing beside them is
// proved not to move any of them:
//   § wildcardImportCopiesPkgVarsToDefNets223  (LIST, never BIND)
//   § ifaceDefNetTypespecIsTheModuleRule224
//   § ifaceDefArrayNetIsAnyUnpackedDim225
//   § uninstIfaceEnumConstNoActual221
//   § uninstIfaceForeachHdrUnresolved220
//   § ifaceOwnCallCalleeFormRoutes222
//   § uninstIfaceBodyBindsInMethodWindow218
package p226i;
   typedef logic [3:0] tv226_t;
   int  pv226;
   tv226_t pav226 [string];
endpackage

interface if226_pi();
   import p226i::*;
   typedef enum { E226_A, E226_B } e226_t;
   e226_t          ev226;
   tv226_t         nv226 [1:0];
   tv226_t         dv226 [];
   int             fa226 [4];
   logic           lg226;

   function automatic int g226(int a226);
      int r226;
      foreach (fa226[i226]) r226 += fa226[i226];
      if (a226 == E226_A) r226 = 1;
      return r226;
   endfunction

   function automatic int h226(int a226);
      return g226(a226);              // the interface's OWN call
   endfunction

   initial begin
      lg226 = 1'b0;
   end
endinterface

module top226_pi;
   logic unused226;
endmodule
