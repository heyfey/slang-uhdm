// r10uvm57repro/v1_prodcell.sv -- THE VERIFIER'S ARM: the PRODUCT cells the
// a1..b5 arm set never built.  Every cell is a reference to a BLOCK-LOCAL
// variable, declared in an UNNAMED block entered at ctrlBodyDepth28 == 1 and
// read at ctrlBodyDepth28 == 1, so § blockLocalSameCtrlDepthArgBinds57's
// depth-equality half is SATISFIED on every one of them.  What varies is the
// OTHER axes the arm set held fixed at "bare reference, direct argument of a
// bare user function call in statement position":
//
//   W1  ref nested inside ANOTHER CALL's argument, outer call in STATEMENT
//       position -- f(g(blkloc)).  b4's e8 measured this in EXPRESSION
//       position only (`e8 = wrap(str8(wrap(n8)))`), where the § classArgBind12
//       window is never opened at all, so the STATEMENT-position product cell
//       is untested and the window IS open there.
//   W2  ref nested inside an OPERATION in the argument -- sinki(bli + 1).
//   W3  ref nested inside a CONCATENATION in the argument -- ClassArgBindOff12
//       turns the window OFF for concat operands, so this must stay BARE.
//   W4  ref under an ELEMENT SELECT / MEMBER SELECT in the argument.
//   W5  BUILT-IN method argument -- § builtinMethodArgBinds28 opens a
//       ClassArgBind12 window at ExprEmit.cpp:9933 for `q.push_back(x)`, a
//       FIFTH call kind the arm set's user/system/receiver/super grid skips.
//   W6  ARGUMENT DIRECTION -- output / inout / ref formals.
//   W7  the two control bodies b2 never wrote: DO-WHILE and FOREVER.
//   W8  SHADOWING -- a block local whose name is also a METHOD-BODY local's.
//
// NEGATIVE CONTROLS carried alongside: the method-body local twin of each new
// shape (golden leaves those bare per § controlBodyNoBind28), and a $display
// twin (a system call never enters the window).
package pv1;
  function automatic void sink(string s); $display(s); endfunction
  function automatic void sinki(int i); $display(i); endfunction
  function automatic string str8(string s); return s; endfunction
  function automatic int wrapi(int i); return i; endfunction
  function automatic void sinko(output string s); s = "o"; endfunction
  function automatic void sinkio(inout string s); s = "io"; endfunction
  function automatic void sinkr(ref string s); s = "r"; endfunction

  typedef struct packed { int f; int g; } sst;

  // ARM-HYGIENE FINDING (refines b4/b5's note, which blamed DERIVED classes):
  // Surelog's CP0332 ("Function sink is not defined for variable this") fires
  // for an unqualified PACKAGE-function call written at the TOP LEVEL (depth 0)
  // of a NON-STATIC class method, in a NON-derived class too.  The same call
  // inside an if-body block is clean, and a STATIC method is clean at any
  // depth.  Measured on /tmp probes t1..t4: t1/t2 (non-static, depth-0 call)
  // -> 1 ERR; t3 (static, depth-0 call) -> 0; t4 (non-static, call only inside
  // the if body) -> 0.  Every method here is therefore STATIC -- which is also
  // the corpus shape (uvm_object_registry::create IS a static function) and
  // b1's own `f`.
  class shp;                         // NOT derived, and every method STATIC
    string prop;
    // ---- W1: nested call, OUTER CALL IN STATEMENT POSITION ----
    static function int w1(int obj);
      string mb;
      mb = "m";
      w1 = obj;
      if (obj == 0) begin
        string b1v;
        b1v = "1";
        sink(b1v);                  // CONTROL: the pinned shape, golden BINDS
        sink(str8(b1v));            // W1a: one call deep, statement position
        sink(str8(str8(b1v)));      // W1b: two calls deep
        sink(str8(mb));             // W1c: method-body local, one deep (neg)
        $display(str8(b1v));        // W1d: SYSTEM outer call (neg)
      end
    endfunction
    // ---- W2/W3: operation and concatenation operands ----
    static function int w2(int obj);
      int mbi;
      mbi = 1;
      w2 = obj;
      if (obj == 0) begin
        int b2i;
        string b2s;
        b2i = 2;
        b2s = "2";
        sinki(b2i);                 // CONTROL
        sinki(b2i + 1);             // W2a: ref under an OPERATION
        sinki(b2i + mbi);           // W2b: block local + method-body local
        sink({b2s, "x"});           // W3a: CONCAT operand -- must stay BARE
        sink({b2s, b2s});           // W3b: both operands the same block local
      end
    endfunction
    // ---- W4: element select and member select in the argument ----
    static function int w4(int obj);
      w4 = obj;
      if (obj == 0) begin
        int b4a[4];
        sst b4s;
        b4a[0] = 1;
        b4s.f = 1;
        sinki(b4a[0]);              // W4a: ELEMENT SELECT of a block local
        sinki(b4s.f);               // W4b: MEMBER SELECT of a block local
        sinki(b4a[b4s.f]);          // W4c: block local as the INDEX too
      end
    endfunction
    // ---- W5: BUILT-IN METHOD argument (§ builtinMethodArgBinds28) ----
    static function int w5(int obj);
      int mq[$];
      string ms;
      ms = "m";
      w5 = obj;
      if (obj == 0) begin
        int b5i;
        int b5q[$];
        b5i = 5;
        mq.push_back(b5i);          // W5a: builtin method, block-local ARG
        b5q.push_back(b5i);         // W5b: builtin method on a block-local
                                    //      RECEIVER, block-local arg
        mq.push_back(obj);          // W5c: FORMAL arg (neg)
        sinki(b5q.size());          // W5d: block local as builtin RECEIVER in
                                    //      an expression-position builtin call
      end
    endfunction
    // ---- W6: ARGUMENT DIRECTION ----
    static function int w6(int obj);
      string mb6;
      mb6 = "m";
      w6 = obj;
      if (obj == 0) begin
        string b6s;
        b6s = "6";
        sink(b6s);                  // CONTROL: input formal
        sinko(b6s);                 // W6a: OUTPUT formal
        sinkio(b6s);                // W6b: INOUT formal
        sinkr(b6s);                 // W6c: REF formal
        sinko(mb6);                 // W6d: OUTPUT formal, body local (neg)
      end
    endfunction
    // ---- W7: DO-WHILE and FOREVER bodies (b2 wrote for/while/repeat/case/
    //          foreach/fork but never these two) ----
    static task w7(int obj);
      int n7;
      n7 = 0;
      do begin
        string b7d;
        b7d = "d";
        sink(b7d);                  // W7a: do-while body block local
        n7 = n7 + 1;
      end while (n7 < 2);
      forever begin
        string b7f;
        b7f = "f";
        sink(b7f);                  // W7b: forever body block local
        return;
      end
    endtask
    // ---- W8: SHADOWING a METHOD-BODY local of the SAME NAME ----
    static function int w8(int obj);
      string shdw;                  // method-body local named `shdw`
      shdw = "outer";
      w8 = obj;
      sink(shdw);                   // W8a: depth 0, the method-body `shdw`
      if (obj == 0) begin
        string shdw;                // block local SHADOWING it, same name
        shdw = "inner";
        sink(shdw);                 // W8b: depth 1, the BLOCK-LOCAL `shdw`
      end
      if (obj == 1) begin
        sink(shdw);                 // W8c: depth 1, the METHOD-BODY `shdw`
                                    //      (no shadow here) -- must stay BARE
      end
    endfunction
  endclass
endpackage

module v1_prodcell;
  int q;
  pv1::shp sh;
  initial q = 0;
  initial sh = null;
endmodule
