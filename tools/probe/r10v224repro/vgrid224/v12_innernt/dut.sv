// r10v224 adversarial arm — the array_net INNER ELEMENT NET's vpiNetType, the
// field netcen224.py does not read.  Same declarations under an INSTANTIATED
// and an UNINSTANTIATED empty-parens interface.
package p224vc;
   typedef struct packed { logic [3:0] a; } spc_t;
   typedef logic [1:0] tvc_t;
endpackage

interface if224vc_u();
   import p224vc::*;
   spc_t vc_sparr224 [1:0];
   tvc_t vc_tdarr224 [1:0];
   int   vc_iarr224  [1:0];
endinterface

interface if224vc_i();
   import p224vc::*;
   spc_t vi_sparr224 [1:0];
   tvc_t vi_tdarr224 [1:0];
   int   vi_iarr224  [1:0];
endinterface

module top224vc;
   if224vc_i uc_224();
endmodule
