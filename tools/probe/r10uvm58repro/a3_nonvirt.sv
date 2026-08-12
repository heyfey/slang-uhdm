// r10uvm58 arm a3 — a NON-VIRTUAL method with a type-parameter return, a
// STATIC one, and a plain (non-class) function with one inside a
// `module #(type T=int)`.  Axis 3.
package p58a3;
   class c_plain #(type T=int);
      function T get();            // non-virtual, in-body
         T r;
         return r;
      endfunction
      static function T sget();    // static
         T r;
         return r;
      endfunction
   endclass
endpackage

module a3_mod58 #(type T=int) ();
   function T mf();                // plain module-scope function
      T r;
      return r;
   endfunction
   initial begin end
endmodule

module a3_top58;
   a3_mod58 u();
endmodule
