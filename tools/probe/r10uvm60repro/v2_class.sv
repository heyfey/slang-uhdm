// VERIFIER ARM v2 — EMPTY-CELL HUNT on the *scope x reachability* PRODUCT.
// The implementer's b6 row R6 declares the cell "class method inside the
// evaluated set" EMPTY because slang forbids a class method as a
// continuous-assign RHS.  But the landed predicate is TRANSITIVE: a plain
// module function that IS a cont-assign RHS may call a CLASS STATIC METHOD,
// which puts a CLASS METHOD in evaldBodies60 after all.  The cell is NOT empty.
// Golden's 400-database census says CLASS_METHOD constant actuals are ALWAYS
// bare; if golden is bare here and we stamp, the landed law OVER-FIRES.
package p62;

   function automatic bit [3:0] h62(bit [3:0] v);
      return v;
   endfunction

   class c62;
      static function bit [3:0] sm(bit [3:0] x);
         return x + h62(1);          // constant actual inside a CLASS METHOD
      endfunction
      function bit [3:0] im(bit [3:0] x);
         return x + h62(1);          // and inside a non-static one
      endfunction
   endclass

endpackage

module v2_class(input logic [3:0] i, output logic [3:0] o, output logic [3:0] o2);
   import p62::*;

   // caller IS the rhs of a continuous assign -> in the seed set; it calls a
   // CLASS STATIC METHOD -> the transitive closure puts c62::sm in the set too.
   function automatic logic [3:0] caller(logic [3:0] x);
      return c62::sm(x);
   endfunction

   // control: a class method reached from nothing evaluated
   c62 hh = new();
   logic [3:0] r2;
   always_comb r2 = hh.im(i);

   assign o  = caller(i);
   assign o2 = r2;
endmodule
