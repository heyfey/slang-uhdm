// r10uvm64 VERIFIER arm v3 — WINDOWS NESTED IN LOOP BODIES, and the two
// control-header positions no arm opened.
//
// b1 uses a `while` and a `for` only as DEPTH-MISMATCH generators: it never
// declares a local INSIDE a loop body and reads it in a condition there, which
// is the same-depth cell the law is about, in the one control shape whose own
// header is NOT a window.  It also never reads a block-local from a FOR HEADER
// or from an `else if` condition or under a `unique`/`priority` qualifier.
//
//   L<NN>  local declared in a WHILE body, read in an if/case CONDITION there
//   M<NN>  local declared in a FOR body, same
//   H<NN>  block-local read in a FOR HEADER (init / cond / step)
//   E<NN>  `else if` chain condition
//   Q<NN>  `unique case` / `priority if` conditions

class v3c;
  int prop;

  function automatic int fl(input int farg);
    int r = 0;
    while (farg == 0) begin
      int L01_loc = 2;
      if (L01_loc == 3) r = 1;              // L01 if COND in a while body, d1==1
      case (L01_loc)                        // L02 case COND in a while body
        4: r = 2;
        default: r = 3;
      endcase
      r = L01_loc;                          // L03 assignment RHS, same depth
      break;
    end
    return r;
  endfunction

  function automatic int fm(input int farg);
    int r = 0;
    for (int i = 0; i < 2; i++) begin
      int M01_loc = 2;
      if (M01_loc == 3) r = 1;              // M01 if COND in a for body, d1==1
      r = M01_loc;                          // M02 assignment RHS, same depth
    end
    return r;
  endfunction

  function automatic int fh(input int farg);
    int r = 0;
    if (farg == 0) begin
      int H01_loc = 2;
      for (int i = 0; i < H01_loc; i++)     // H01 FOR-HEADER condition operand
        r = r + 1;
      for (int j = H01_loc; j < 3; j++)     // H02 FOR-HEADER init operand
        r = r + 1;
    end
    return r;
  endfunction

  function automatic int fe(input int farg);
    int r = 0;
    if (farg == 0) begin
      int E01_loc = 2;
      if (E01_loc == 3) r = 1;              // E01 leading if COND
      else if (E01_loc == 4) r = 2;         // E02 `else if` COND
      else r = 3;
    end
    return r;
  endfunction

  function automatic int fq(input int farg);
    int r = 0;
    if (farg == 0) begin
      int Q01_loc = 2;
      unique case (Q01_loc)                 // Q01 UNIQUE CASE condition
        5: r = 1;
        default: r = 2;
      endcase
      priority if (Q01_loc == 6) r = 3;     // Q02 PRIORITY IF condition
      else r = 4;
    end
    return r;
  endfunction
endclass

module v3_top;
  v3c h;
  int r;
  initial begin
    h = new();
    r = h.fl(0);
    r = h.fm(0);
    r = h.fh(0);
    r = h.fe(0);
    r = h.fq(0);
  end
endmodule
