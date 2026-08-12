// r10uvm58 arm a7 — the type parameter used as BOTH the return type and a
// FORMAL type, so the two can be told apart in the listing.  Axis 7.
package p58a7;
   virtual class c_both #(type T=int);
      pure virtual function T f(T x);
      pure virtual function T g(output T y);
      pure virtual function bit h(T x, output T y);
   endclass
endpackage

module a7_top58;
   initial begin end
endmodule
