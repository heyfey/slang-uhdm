// r10uvm58 arm a6 — the EXTERN / OUT-OF-BODY method with a type-parameter
// return, and THE NEGATIVE CONTROL: a pure virtual in a NON-parameterised
// class, which must keep whatever it has today.  Axis 6.
package p58a6;
   class c_ext #(type T=int);
      extern function T get();
      extern function bit ok();
   endclass

   function c_ext::T c_ext::get();
      T r;
      return r;
   endfunction

   function bit c_ext::ok();
      return 1;
   endfunction

   virtual class c_negctl;            // NEGATIVE CONTROL: no type parameter
      pure virtual function int  get();
      pure virtual function bit  ok();
   endclass
endpackage

module a6_top58;
   initial begin end
endmodule
