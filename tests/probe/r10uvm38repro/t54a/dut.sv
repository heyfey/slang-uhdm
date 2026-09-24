// r10uvm38 t54a — does the ARGUMENT of a `this.`-rooted method call bind the
// enclosing method's FORMAL?  Pass 38's residue says golden binds it and we
// leave it null, in 54 rows of SeqDriver, all of them an INLINE class method
// whose whole body is one `this.<m>(formals...)` call (uvm_sequence_item's and
// uvm_report_catcher's uvm_report_* wrappers).  The controls in the same cell
// are a `super.`-rooted call (agreed BOUND on both sides in the corpus) and a
// bare unqualified call.
package home54;

   class base54;
      function new(string nm = "");
      endfunction
      function void deep54(int d, string ds);
      endfunction
   endclass

   class c54 extends base54;
      int acc;

      function void inner54(int x, string s);
         acc = x;
      endfunction

      // THE CELL: one `this.`-rooted call, arguments are this method's formals.
      function void thisCall54(int y, string t);
         this.inner54(y, t);
      endfunction

      // CONTROL A: the same call unqualified.
      function void bareCall54(int y2, string t2);
         inner54(y2, t2);
      endfunction

      // CONTROL B: a `super.`-rooted call (the corpus's agreed-bound shape).
      function new(string nm2 = "");
         super.new(nm2);
      endfunction

      // CONTROL C: a `this.`-rooted call in EXPRESSION position.
      function int thisExpr54(int y3);
         return this.inner55(y3);
      endfunction

      // CONTROL D: a DEEP `this.<member>.m(...)` in STATEMENT position — the
      // half the first cut of § thisRecvCallArgBind38 did not measure, and the
      // shape UVM's TLM forwarding macros are made of.
      base54 nested;
      function void thisDeep54(int y4, string t4);
         this.nested.deep54(y4, t4);
      endfunction

      function int inner55(int z);
         return z;
      endfunction
   endclass

endpackage

module top54;
   import home54::*;
   c54 h;
   initial h = new("x");
endmodule
