// r10svs4repro/v2_copy.sv — VERIFIER arm for LAW 2, § copyClassIsNewCall4.
//
// The shipped patch adds an `ExpressionKind::CopyClass` arm that previously
// returned NULL.  Turning a null into a node changes STATEMENT emission, and
// this campaign already has a law (r10svs3's § thisSuperNewAssignNoStmt3) that
// suppresses the whole statement for `this.x = new(...)`.  So the cells that
// matter are the ones where a CopyClass lands in a position the old null was
// silently absorbing:
//
//   * a plain local target (the measured cell: Driver.sv:38)
//   * a THIS-rooted target (does r10svs3's no-statement law still govern?)
//   * a MEMBER target reached through a handle
//   * an ARRAY-ELEMENT target
//   * a CALL ARGUMENT / a RETURN expression / a declaration INITIALIZER
//   * a module-scope (non-class-method) target
class P;
   int a;
   byte data[];
endclass

class Q;
   P p;
   P parr[2];
   function void f(P gp, Q o);
      P lp;
      lp = new gp;              // w1 plain local target  (the measured cell)
      this.p = new gp;          // w2 THIS-rooted target
      o.p = new gp;             // w3 handle-member target
      this.parr[0] = new gp;    // w4 array-element target, this-rooted
      o.parr[1] = new gp;       // w5 array-element target, handle
      lp = new gp;              // w6 second plain target (repeat)
   endfunction
   function void g(P x); endfunction
   function P h(P gp);
      P t;
      t = new gp;               // w7 target then returned
      return t;
   endfunction
   function void i(P gp);
      P dp = new gp;            // w8 declaration INITIALIZER
      if (dp != null) dp.a = 1;
   endfunction
endclass

module mw;
   P gp;
   P np;
   initial begin
      np = new gp;              // w9 MODULE scope target
   end
endmodule
