// b5_negctl — the NEGATIVE CONTROL for the r10uvm60 law: the cells where the
// formal-typespec stamp (and its formal-width constant resize) is CORRECT and
// must survive untouched.  NOTHING here is inside a class.
//   N1 module function, vector formal, constant actual  (`loop(2)` prior art:
//      the stamp resizes the literal to the formal's width)
//   N2 module function, ref actual
//   N3 package function called as a continuous-assign RHS (pkgTopEmit arm)
//   N4 module function body's nested call with an operation actual
package p65;
   function automatic logic [3:0] pkgf(logic [3:0] a);
      return a + 1;
   endfunction
endpackage

module b5_negctl(input logic [3:0] inp, output logic [3:0] out1, out2);
   import p65::*;

   function automatic logic [3:0] loop(logic [3:0] n);
      return n;
   endfunction

   function automatic logic [3:0] pow_a(logic [3:0] base, logic [3:0] exp);
      if (exp == 0)
        return 1;
      else
        return base * pow_a(base, exp - 1);   // N4 — operation actual
   endfunction

   logic [3:0] r1, r2;
   always_comb begin
      r1 = loop(2);        // N1 — constant actual, vector formal
      r2 = loop(inp);      // N2 — ref actual
   end

   assign out1 = pkgf(inp);          // N3 — package function as CA RHS
   assign out2 = pow_a(inp, 3);
endmodule
