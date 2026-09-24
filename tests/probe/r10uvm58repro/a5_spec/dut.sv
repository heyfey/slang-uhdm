// r10uvm58 arm a5 — THE SPECIALIZATION AXIS.  The DEFAULT specialization, an
// EXPLICIT #(int), an EXPLICIT #(string), and a class SPECIALIZED TWICE.  Axis
// 5: golden's typespec sharing and var kind may differ per specialization, and
// def-view / elab-view listings are known to disagree.
package p58a5;
   virtual class base #(type T=int);
      pure virtual function T get();
   endclass

   class useint extends base #(int);
      virtual function int get(); return 0; endfunction
   endclass

   class usestr extends base #(string);
      virtual function string get(); return ""; endfunction
   endclass

   class holder;
      base #(int)    h_i;
      base #(string) h_s;
      base #(int)    h_i2;
   endclass
endpackage

module a5_top58;
   initial begin end
endmodule
