// r10uvm58 VERIFIER v3 — the CLASS specialization probe with an explicit
// override reached through a variable declaration AND through an extends, in
// the same file, to settle whether any golden listing of a specialized generic
// class resolves a type-parameter return to a concrete var class.
package p58v3;
   class g58 #(type T=int);
      function T get();
         T r;
         return r;
      endfunction
   endclass

   class useit;
      g58 #(int)    a;
      g58 #(string) b;
      g58           c;   // default specialization
   endclass

   class ext58 extends g58 #(byte);
   endclass
endpackage

module v3_top58;
   initial begin end
endmodule
