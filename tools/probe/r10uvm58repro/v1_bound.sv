// r10uvm58 VERIFIER v1 — the OVER-FIRE probe on what a type parameter can be
// BOUND to that is not a scalar: an unpacked array, a queue, an associative
// array, a dynamic array, a virtual interface and another PARAMETERISED class.
// Surelog's compileVariable falls through to ref_var for every binding whose
// typespec is not a class_typespec, so all of these are predicted ref_var
// EXCEPT the parameterised-class one.
interface if58; logic a; endinterface

package p58v1;
   typedef int arr58_t [3];
   typedef int q58_t [$];
   typedef int as58_t [string];
   typedef int dy58_t [];
   class kk58 #(type W=int); W w; endclass

   virtual class b_arr  #(type T=arr58_t)     ; pure virtual function T get(); endclass
   virtual class b_q    #(type T=q58_t)       ; pure virtual function T get(); endclass
   virtual class b_as   #(type T=as58_t)      ; pure virtual function T get(); endclass
   virtual class b_dy   #(type T=dy58_t)      ; pure virtual function T get(); endclass
   virtual class b_pcls #(type T=kk58#(int))  ; pure virtual function T get(); endclass
   virtual class b_vif  #(type T=virtual if58) ; pure virtual function T get(); endclass
endpackage

module v1_top58;
   initial begin end
endmodule
