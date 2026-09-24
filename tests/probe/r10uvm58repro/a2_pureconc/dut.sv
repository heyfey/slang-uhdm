// r10uvm58 arm a2 — THE DECIDER, BUILT FIRST.
// A PURE VIRTUAL whose return type is CONCRETE, in a PARAMETERISED virtual
// class (c1) and in a NON-parameterised virtual class (c2).  If golden gives
// these a ref_var then "pure virtual" owns the law; if it gives the concrete
// var kind then the TYPE PARAMETER owns it.
package p58a2;
   virtual class c1 #(type T=int);
      pure virtual function int  gi();
      pure virtual function bit  gb();
      pure virtual function string gs();
   endclass

   virtual class c2;
      pure virtual function int  gi();
      pure virtual function bit  gb();
      pure virtual function string gs();
   endclass
endpackage

module a2_top58;
   initial begin end
endmodule
