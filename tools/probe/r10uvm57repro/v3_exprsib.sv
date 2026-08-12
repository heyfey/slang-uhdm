// r10uvm57repro/v3_exprsib.sv -- THE OVER-FIRE ARM.
//
// THE PRODUCT CELL THE ARM SET SKIPPED: call kind = UNQUALIFIED SIBLING CLASS
// METHOD  x  position = EXPRESSION.  b4 covers
//   * unqualified sibling method in STATEMENT position   (e1:35 `im(p0)`)
//   * PACKAGE function in EXPRESSION position            (e2:59 `wrap(r2)`,
//     e7:96 `return wrap(n7)`, e8:106 `wrap(str8(wrap(n8)))`)
// and concludes "the EXPRESSION-position cells correctly stay bare ...
// § classInBodyBareCallArgStmtOnly53 already withheld the window there and the
// carve-out inherits it".  The PRODUCT of those two axes is never written, and
// it is the one that behaves differently: for a BARE call to a SIBLING METHOD
// of the same class, our emitter DOES open the § classArgBind12 window in
// expression position, so § blockLocalSameCtrlDepthArgBinds57 fires there.
//
// THE CORPUS SITE, verbatim in shape -- uvm-1.2 uvm_reg_map.svh
// `uvm_reg_map::clone_and_update`, at the single-unit BuildUVMPkg dump's
// lines 75319-75322 and again at 75324-75327:
//     begin                                  // unnamed block, ctrlBodyDepth 1
//       uvm_reg rg;                          // 75320:13  block local
//       info = get_reg_map_info(rg);         // 75321:46  EXPRESSION position
//       add_reg(rg, info.offset, ...);       // 75322:15  STATEMENT position
//     end
// GOLDEN binds 75322:15 and leaves 75321:46 BARE.  The pristine binary bound
// NEITHER; the patched binary binds BOTH.  The second one is an OVER-FIRE.
//
// D1 is that shape.  D2..D5 vary the expression context (operand of a bigger
// expression, return statement, nested inside another sibling call, and a
// receiver-qualified twin) and D6..D7 are the negative controls: the PACKAGE
// function in the same positions (golden bare, we are bare), and the
// method-body local (golden bare everywhere).
package pv3;
  function automatic int pwrap(int i); return i; endfunction
  function automatic void psink(int i); $display(i); endfunction

  class base3;
    function int bmeth(int i); return i; endfunction
  endclass

  class shp;                            // NOT derived; every method STATIC
    base3 o;
    static function int getinfo(int i); return i + 1; endfunction
    static function void useit(int i); $display(i); endfunction
    static function int wrapi(int i); return i; endfunction

    // ---- D1: THE CORPUS SHAPE.  assignment whose RHS is an unqualified
    //          SIBLING-METHOD call taking the block local; the statement-
    //          position sibling call on the next line is the control that
    //          golden DOES bind.
    static function int d1(int obj);
      int info;
      d1 = obj;
      if (obj == 0) begin
        int rg;
        rg = 1;
        info = getinfo(rg);        // D1a: EXPRESSION position, SIBLING method
        useit(rg);                 // D1b: STATEMENT position, SIBLING method
        d1 = info;
      end
    endfunction
    // ---- D2: the same call as an OPERAND of a bigger expression
    static function int d2(int obj);
      d2 = obj;
      if (obj == 0) begin
        int r2;
        r2 = 2;
        d2 = getinfo(r2) + 1;      // D2a: sibling call inside an operation
      end
    endfunction
    // ---- D3: RETURN expression
    static function int d3(int obj);
      if (obj == 0) begin
        int r3;
        r3 = 3;
        return getinfo(r3);        // D3a: sibling call in a return
      end
      return obj;
    endfunction
    // ---- D4: nested sibling calls, expression position
    static function int d4(int obj);
      d4 = obj;
      if (obj == 0) begin
        int r4;
        r4 = 4;
        d4 = getinfo(wrapi(r4));   // D4a: two sibling calls deep
      end
    endfunction
    // ---- D5: RECEIVER-QUALIFIED twin (§ classInBodyRecvCallArgNoBind52
    //          territory: must stay bare)
    static function int d5(int obj);
      d5 = obj;
      if (obj == 0) begin
        int r5;
        r5 = 5;
        d5 = 0;                    // (o is a static-context handle; only the
                                   //  bare/package cells matter here)
      end
    endfunction
    // ---- D6: NEGATIVE CONTROL -- PACKAGE function, same positions
    static function int d6(int obj);
      int i6;
      d6 = obj;
      if (obj == 0) begin
        int r6;
        r6 = 6;
        i6 = pwrap(r6);            // D6a: package fn, EXPRESSION position
        psink(r6);                 // D6b: package fn, STATEMENT position
        d6 = i6;
      end
    endfunction
    // ---- D7: NEGATIVE CONTROL -- METHOD-BODY local in both positions
    static function int d7(int obj);
      int mb7;
      int i7;
      mb7 = 7;
      d7 = obj;
      if (obj == 0) begin
        i7 = getinfo(mb7);         // D7a: body local, EXPRESSION position
        useit(mb7);                // D7b: body local, STATEMENT position
        d7 = i7;
      end
    endfunction
    // ---- D8: THE DISCRIMINATOR.  The sibling method is declared BELOW the
    //          caller, so it is not in subMap yet and the call takes
    //          § classCallNoLink12's branch (ExprEmit.cpp ~8747) -- the ONE
    //          ClassArgBind12 window in the file that is opened WITHOUT
    //          § classInBodyBareCallArgStmtOnly53's statement-position gate.
    //          D1a took the RESOLVED path (callee declared above) and stayed
    //          bare on both binaries; this is its unresolved twin.
    static function int d8(int obj);
      int i8;
      d8 = obj;
      if (obj == 0) begin
        int r8;
        r8 = 8;
        i8 = late8(r8);            // D8a: EXPRESSION position, callee BELOW
        late8v(r8);                // D8b: STATEMENT position, callee BELOW
        d8 = i8 + late8(r8) ;      // D8c: same call as an OPERAND
        d8 = late8(late8(r8));     // D8d: nested, both unresolved
      end
    endfunction
    static function int late8(int i); return i; endfunction
    static function void late8v(int i); $display(i); endfunction
  endclass
endpackage

module v3_exprsib;
  int q;
  pv3::shp s3;
  initial q = 0;
  initial s3 = null;
endmodule
