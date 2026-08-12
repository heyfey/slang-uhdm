// r10uvm58 VERIFIER arm w3 — THE CLASS-PROPERTY PRODUCT CELLS v4 SKIPPED.
// v4_contprop covers `T q[$]`, `T a[3]` and `T as[string]` as class
// properties; it does NOT cover a DYNAMIC-array property `T dyn[]` (a
// distinct factory), a STATIC property, a RAND property, or a property
// declared through a TYPEDEF ALIAS to the type parameter.  The exclusion the
// pass landed lives at ONE call site (classElemVar), so any property path
// that does NOT go through it is an over-fire candidate: golden resolves
// class properties (ElaborationStep's Parameter branch) and therefore every
// cell here must stay a CONCRETE var on both sides.
package p58w3;
   class c_w3 #(type T = int);
      static T s_prop;              // STATIC class property of T
      rand T r_prop;                // RAND class property of T
      T dyn_prop [];                // DYNAMIC-array property of T
      typedef T alias_w3_t;
      alias_w3_t alias_prop;        // property through a TYPEDEF ALIAS to T
      alias_w3_t alias_q [$];       // container property through the alias
      function bit m();
         T dloc [];                 // dynamic-array LOCAL (positive control)
         alias_w3_t aloc;           // alias LOCAL
         dloc = dyn_prop;
         aloc = alias_prop;
         return 1;
      endfunction
      function T get_it();          // the landed law's own cell (control)
         return r_prop;
      endfunction
   endclass
endpackage

module w3_top58;
   initial begin end
endmodule
