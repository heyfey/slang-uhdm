// r10uvm58 VERIFIER v2 — THE ELAB-VIEW OVER-FIRE PROBE.  A module type
// parameter is the one shape that gets BOTH a def-view and an ELABORATED
// listing, and the campaign already knows the two views disagree.  m58 is
// instantiated twice with two DIFFERENT overrides and once at its default, so
// if golden resolves the elaborated return var to the OVERRIDE's concrete var
// class this arm shows it and the law must be view-scoped.
module m58 #(type T = int) ();
   function T mf();
      T r;
      return r;
   endfunction
   initial begin end
endmodule

module v2_top58;
   m58 #()        u_def ();
   m58 #(string)  u_str ();
   m58 #(byte)    u_byt ();
endmodule
