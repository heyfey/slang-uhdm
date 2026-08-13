// r10uvm64 arm b1 — THE CONDITION WINDOW, with block-locals.
//
// THE CORPUS WITNESS this arm re-writes in miniature, uvm-1.2
// src/base/uvm_recorder.svh:338..354 (`function integer get_handle`):
//
//     if (!is_open() && !is_closed()) begin  return 0;  end
//     else begin
//        integer handle = get_inst_id();                 // 343
//        if (m_ids_by_recorder.exists(this) &&
//            m_ids_by_recorder[this] != handle)          // 346:75  golden BINDS
//          m_recorders_by_id.delete(m_ids_by_recorder[this]);
//        m_recorders_by_id[handle] = this;               // 349:28  golden BARE
//        m_ids_by_recorder[this] = handle;               // 350:36  golden BARE
//        return handle;                                  // 352:17  golden BARE
//     end
//
// Golden binds `handle` at EXACTLY ONE of its four use sites: the if CONDITION.
// That single asymmetry is the whole discriminator this arm measures, and it is
// why the pass is NOT about emitting a missing variable (we emit it, byte for
// byte — see README §1.1) but about ONE vpiActual edge.
//
// The cells are named c<NN>_ and every one of them is read by ct64cells.py off
// the ref's LINE:COL, which is identical on both sides.

class b1c;
  int prop;
  int q[int];

  // ---------------------------------------------------------------- f1
  // The direct transcription of the witness: a block-local declared in the
  // UNNAMED `else begin`, read four ways at the SAME control depth.
  function automatic int f1(input int farg);
    int bodyloc = 1;
    int r = 0;
    if (farg == 0) begin
      r = 100;
    end
    else begin
      int c01_blkloc = 2;                 // decl, depth 1, unnamed block
      if (c01_blkloc == 3) r = 2;         // c01 CONDITION, depth 1
      r = c01_blkloc;                     // c02 assignment RHS, depth 1
      q[c01_blkloc] = 4;                  // c03 LHS bit-select index, depth 1
      if (bodyloc == 5) r = 5;            // c05 METHOD-BODY local in a cond, d1
      if (prop == 6) r = 6;               // c09 class PROPERTY in a cond, d1
      if (farg == 7) r = 7;               // c10 FORMAL in a cond, d1
      return c01_blkloc;                  // c04 return operand, depth 1
    end
    return r;
  endfunction

  // ---------------------------------------------------------------- f2
  // The DEPTH axis, and the two shapes that do not raise the depth.
  function automatic int f2(input int farg);
    int r = 0;
    if (farg == 0) begin
      int c20_blkloc = 2;                 // decl at depth 1
      if (r == 8) begin
        if (c20_blkloc == 9) r = 9;       // c07 read at depth 2 (MISMATCH)
      end
      begin
        if (c20_blkloc == 10) r = 10;     // c14 nested PLAIN begin, still d1
      end
      while (c20_blkloc == 11) r = 11;    // c13 WHILE condition, d1
      case (c20_blkloc)                   // c12 CASE condition, d1
        12: r = 12;
        default: r = 13;
      endcase
      for (int i = 0; i < 2; i++)
        if (c20_blkloc == 14) r = 14;     // c15 read at depth 2 through a for
    end
    return r;
  endfunction

  // ---------------------------------------------------------------- f3
  // The NAMED-block exclusion and the depth-0 controls.
  function automatic int f3(input int farg);
    int r = 0;
    int bodyloc = 3;
    if (bodyloc == 0) r = 1;              // c06 body local, cond at DEPTH 0
    begin : nmd
      int c08_nmdblk = 4;                 // NAMED block at depth 0
      if (c08_nmdblk == 5) r = 5;         // c08 named-block local, cond d0
    end
    begin
      int c11_pln0 = 6;                   // UNNAMED block at depth 0
      if (c11_pln0 == 7) r = 7;           // c11 plain-block local, cond d0
    end
    if (farg == 1) begin : nmd1
      int c16_nmd1 = 8;                   // NAMED block at depth 1
      if (c16_nmd1 == 9) r = 9;           // c16 named-block local, cond d1
    end
    return r;
  endfunction

  // ---------------------------------------------------------------- f4
  // Is the carve-out CONDITION-shaped or WINDOW-shaped?  Every other position
  // reachable at depth 1 with a same-depth block-local.
  function automatic int f4(input int farg);
    int r = 0;
    if (farg == 0) begin
      int c30_blkloc = 2;
      if (c30_blkloc + 1 == 3) r = 1;     // c30 cond, ref under an OPERATION
      if (sink(c30_blkloc)) r = 2;        // c31 cond, ref inside a CALL arg
      sink2(c30_blkloc);                  // c32 STATEMENT-position call arg
      r = sink(c30_blkloc);               // c33 EXPRESSION-position call arg
      $display("%0d", c30_blkloc);        // c34 SYSTEM call argument
      q[1] = c30_blkloc;                  // c35 RHS of an indexed assignment
      if (c30_blkloc inside {1, 2}) r = 3;// c36 cond, inside-expression operand
    end
    return r;
  endfunction

  function automatic int sink(input int a);
    return a;
  endfunction

  function automatic void sink2(input int a);
    prop = a;
  endfunction
endclass

module b1_top;
  b1c h;
  int r;
  initial begin
    h = new();
    r = h.f1(0);
    r = h.f2(0);
    r = h.f3(0);
    r = h.f4(0);
  end
endmodule
