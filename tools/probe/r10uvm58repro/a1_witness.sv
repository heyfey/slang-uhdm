// r10uvm58 arm a1 — THE WITNESS and its NON-PURE TWIN.
// c_pure reproduces uvm_set_get_dap_base: `pure virtual function T get();` in a
// `#(type T=int)` VIRTUAL class.  c_body is the non-pure twin (the cell that
// separates "pure virtual" from "type parameter"), reproducing
// uvm_set_before_get_dap::get.
package p58a1;
   virtual class c_pure #(type T=int);
      pure virtual function void   setv(T value);
      pure virtual function bit    try_setv(T value);
      pure virtual function T      get();
      pure virtual function bit    try_getv(output T value);
   endclass

   virtual class c_body #(type T=int);
      local T m_value;
      virtual function T get();
         return m_value;
      endfunction
      virtual function bit try_getv(output T value);
         value = m_value;
         return 1;
      endfunction
   endclass
endpackage

module a1_top58;
   initial begin end
endmodule
