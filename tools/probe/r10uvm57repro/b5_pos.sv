// r10uvm57repro/b5_pos.sv -- THE OVER-FIRE GUARD ARM.  b4 showed that at
// ctrlBodyDepth 1 a block local binds in `sink(x);` but NOT in
// `return wrap(x)` / `y = wrap(x)`.  § classArgBind12's window is already
// gated on STATEMENT position for an in-body class method (ExprEmit ~9142,
// `callStmtCtx0 || !(curSubClassScope9 && !curSubOob9)`), so exempting
// ctrlBodyNoBind28 must NOT make those bind.  This arm measures the SAME
// positions at DEPTH 0, where no exemption is involved, so it says what the
// existing gate already does and therefore what the exemption will inherit.
package pb5;
  function automatic void sink(string s); $display(s); endfunction
  function automatic int wrap(string s); return 1; endfunction
  function automatic string str8(int i); return "z"; endfunction

  class base5;
    function void bm(string s); endfunction
  endclass

  class shp;
    base5 o;
    function void im(string s); endfunction
    // depth 0, METHOD-BODY local, every call position
    function int p0(int obj);
      string mb;
      mb = "m";
      p0 = obj;
      sink(mb);                 // STATEMENT call
      im(mb);                   // STATEMENT sibling-method call
      o.bm(mb);                 // STATEMENT receiver call
      p0 = wrap(mb);            // assignment RHS
      p0 = wrap(str8(wrap(mb)));// nested two deep
      p0 = wrap(mb) + 1;        // operand of an operation
      if (wrap(mb) == 1) p0 = 2;// inside an if CONDITION
      while (wrap(mb) == 9) p0 = 3; // inside a while CONDITION
    endfunction
    function int p0r(int obj);
      string mb;
      mb = "m";
      return wrap(mb);          // return expression
    endfunction
    // depth 0, PLAIN-BLOCK local, every call position
    function int pb(int obj);
      pb = obj;
      begin
        string bl;
        bl = "b";
        im(bl);                 // STATEMENT sibling-method call
        o.bm(bl);               // STATEMENT receiver call
        pb = wrap(bl);          // assignment RHS
        pb = wrap(str8(wrap(bl)));
        if (wrap(bl) == 1) pb = 2;
      end
    endfunction
    // depth 1, METHOD-BODY local, the same positions (control for b4's block
    // local cells: ctrlBodyNoBind28 must keep silencing ALL of these)
    function int p1(int obj);
      string mb;
      mb = "m";
      p1 = obj;
      if (obj == 0) begin
        sink(mb);
        im(mb);
        o.bm(mb);
        p1 = wrap(mb);
        if (wrap(mb) == 1) p1 = 2;
      end
    endfunction
  endclass
endpackage

module b5_pos;
  int q;
  initial q = 0;
  pb5::shp sh;
  initial sh = null;
endmodule
