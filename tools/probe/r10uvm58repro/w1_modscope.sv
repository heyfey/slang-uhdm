// r10uvm58 VERIFIER arm w1 — THE EMPTY PRODUCT CELL a3/v2 SKIPPED.
// Both of the implementer's module arms declare only FUNCTIONS inside
// `module #(type T=int)`; neither declares a module-scope or interface-scope
// VARIABLE of type T, and neither uses T as a PORT type or a STRUCT MEMBER.
// This matters because ModuleEmit.cpp:6258 -> emitDynArrayVar ->
// makeReturnVar is a MODULE-scope path into the gated factory, so a
// module-scope `T dyn[];` element reg is reachable by the law and was never
// measured.  PREDICTION UNDER THE LANDED LAW: these all become ref_var.
// If golden RESOLVES any of them, that is an OVER-FIRE.
interface if58w #(type T = int) ();
   T ivar;                          // INTERFACE-scope variable of T
   T iq [$];                        // INTERFACE-scope queue of T
endinterface

module m58w #(type T = int) ();
   T mvar;                          // MODULE-scope scalar variable of T
   T marr [3];                      // MODULE-scope FIXED array of T
   T mq [$];                        // MODULE-scope QUEUE of T
   T mdyn [];                       // MODULE-scope DYNAMIC array of T
   T mas [string];                  // MODULE-scope ASSOCIATIVE array of T
   typedef struct packed { T f; } s58w_t;
   s58w_t svar;                     // STRUCT MEMBER of T
   function T mf();                 // control: the a3 cell, must stay ref_var
      T r;
      return r;
   endfunction
   initial begin end
endmodule

module mp58w #(type T = int) (input T pin, output T pout);
   T pmid;                          // module-scope var next to T PORTS
   assign pout = pin;
endmodule

module w1_top58 ();
   int pa;
   int pb;
   m58w  u_m ();
   mp58w u_p (.pin(pa), .pout(pb));
   if58w u_i ();
   initial begin end
endmodule
