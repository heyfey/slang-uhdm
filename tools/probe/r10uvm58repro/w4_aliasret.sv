// r10uvm58 VERIFIER arm w4 — the LAST TWO EMPTY PRODUCT CELLS.
//  (a) a TYPE-PARAMETER RETURN reached through a TYPEDEF ALIAS
//      (`typedef T my_t; function my_t f();`).  Every implementer arm writes
//      `T` directly at the return token, so the alias-return cell is empty,
//      and the gate cannot see it (a typedef's syntax kind is
//      TypedefDeclaration, not TypeAssignment) — so this cell decides whether
//      the landed gate UNDER-fires on a shape golden treats the same way.
//  (b) a method returning the type parameter of an INTERFACE and of a class
//      NESTED inside a parameterised class — two scopes no arm reaches.
interface if58w4 #(type T = int) ();
   function T iget();                 // INTERFACE-scope method returning T
      T r;
      return r;
   endfunction
endinterface

package p58w4;
   class c_outer #(type T = int);
      typedef T alias_w4_t;
      function alias_w4_t aget();     // RETURN through a TYPEDEF ALIAS to T
         alias_w4_t r;
         return r;
      endfunction
      function T tget();              // control: T written directly
         T r;
         return r;
      endfunction
      class c_inner;                  // NESTED class inside the generic
         function int nget();
            return 0;
         endfunction
      endclass
   endclass
endpackage

module w4_top58 ();
   if58w4 u_i ();
   initial begin end
endmodule
