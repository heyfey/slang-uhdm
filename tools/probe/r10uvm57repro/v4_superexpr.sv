// r10uvm57repro/v4_superexpr.sv -- THE SECOND EMPTY SQUARE OF THE SAME FAMILY:
// call kind = `super.<m>` / `this.<m>` / receiver  x  position = EXPRESSION.
//
// b4 measures `super.bm(s3)` and `this.im(t4)` in STATEMENT position only, and
// the pass's own note claims "the EXPRESSION-position and receiver-qualified
// cells stay bare" because § classInBodyRecvCallArgNoBind52 still applies.  It
// applies at THREE sites only (`RecvCallArg52` at ExprEmit.cpp 8407, 8483,
// 8617 and 10128).  The `super.` arm at ExprEmit.cpp ~7955
// (§ superMethodCall17) opens a ClassArgBind12 window UNCONDITIONALLY -- it
// even sets `callStmtContext = false` first -- and raises NO RecvCallArg52, so
// nothing in the file withholds the window from an expression-position
// `super.` call.  Whether that is an over-fire is a question for GOLDEN.
//
//   S1a  `super.bv(r1);`          STATEMENT position   (b4's covered cell)
//   S1b  `i1 = super.bm(r1);`     EXPRESSION position  <-- THE EMPTY SQUARE
//   S1c  `e1 = i1 + super.bm(r1)` OPERAND
//   S1d  `return super.bm(r1);`   RETURN
//   S2a  `this.iv(r2);`           STATEMENT position
//   S2b  `i2 = this.im(r2);`      EXPRESSION position
//   S3a  `o.bv(r3);`              receiver, STATEMENT position
//   S3b  `i3 = o.bm(r3);`         receiver, EXPRESSION position (§52's own
//                                 cell: must stay bare)
//   S4   METHOD-BODY-local negative twins of S1b and S3b.
package pv4;
  // NOTE: no `$display` inside a class method -- with `-nobuiltin` Surelog
  // reports CP0333 "Undefined system task/function $display" for a system call
  // written in a CLASS body (it does not for one in a package function, which
  // is why a1..b5 never hit it).  A golden produced under an error is an
  // error-recovery, not a golden, so every void method here writes a member.
  class base4;
    int sinkm;
    function int bm(int i); return i + 1; endfunction
    function void bv(int i); sinkm = i; endfunction
  endclass

  class der4 extends base4;
    base4 o;
    function int e1(int obj);
      int i1;
      e1 = obj;
      if (obj == 0) begin
        int r1;
        r1 = 1;
        super.bv(r1);              // S1a
        i1 = super.bm(r1);         // S1b  <-- the empty square
        e1 = i1 + super.bm(r1);    // S1c
      end
    endfunction
    function int e1d(int obj);
      if (obj == 0) begin
        int r1d;
        r1d = 1;
        return super.bm(r1d);      // S1d
      end
      return obj;
    endfunction
    function void iv(int i); sinkm = i; endfunction
    function int im(int i); return i; endfunction
    function int e2(int obj);
      int i2;
      e2 = obj;
      if (obj == 0) begin
        int r2;
        r2 = 2;
        this.iv(r2);               // S2a
        i2 = this.im(r2);          // S2b
        e2 = i2;
      end
    endfunction
    function int e3(int obj);
      int i3;
      e3 = obj;
      if (obj == 0) begin
        int r3;
        r3 = 3;
        o.bv(r3);                  // S3a
        i3 = o.bm(r3);             // S3b
        e3 = i3;
      end
    endfunction
    function int e4(int obj);
      int mb4;
      int i4;
      mb4 = 4;
      e4 = obj;
      if (obj == 0) begin
        i4 = super.bm(mb4);        // S4a: body local, super, EXPRESSION
        super.bv(mb4);             // S4b: body local, super, STATEMENT
        i4 = o.bm(mb4);            // S4c: body local, receiver, EXPRESSION
        e4 = i4;
      end
    endfunction
  endclass
endpackage

module v4_superexpr;
  int q;
  pv4::der4 d4;
  initial q = 0;
  initial d4 = null;
endmodule
