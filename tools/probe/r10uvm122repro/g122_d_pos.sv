// r10uvm122 arm d — the REFERENCE-POSITION face and the negatives.
package p122d;
  function int helper122 (int x); return x; endfunction

  // d1 — reference on the assignment LHS AND RHS of one statement
  function int d1_both (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin v = v + 1; v[0] = 1; end
    return v;
  endfunction

  // d2 — reference in an IF CONDITION
  function int d2_cond (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      if (v == 3) v = 4;
      v[0] = 1;
    end
    return v;
  endfunction

  // d3 — reference as a CALL ARGUMENT
  function int d3_arg (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      v = helper122(v);
      v[0] = 1;
    end
    return v;
  endfunction

  // d4 — reference as a SELECT INDEX
  function int d4_idx (int unsigned s);
    bit [31:0] v; int a [0:31]; v = 1;
    if (s) begin
      a[v] = 2;
      v[0] = 1;
    end
    return a[0];
  endfunction

  // d5 — reference in a RETURN inside the block
  function int d5_ret (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      v[0] = 1;
      return v;
    end
    return 0;
  endfunction

  // d6 — NEGATIVE: the only select is an RVALUE, never an assignment LHS
  function int d6_rvalonly (int unsigned s);
    bit [31:0] v; int r; v = 1;
    if (s) begin
      r = v[3];
      v ^= 3;                    // cell d6r  -- must stay on the declaration
    end
    return r;
  endfunction

  // d7 — an RVALUE select BEFORE the lvalue one in the same block
  function int d7_rvalfirst (int unsigned s);
    bit [31:0] v; int r; v = 1;
    if (s) begin
      r = v[3];
      v ^= 3;                    // cell d7r
      v[0] = 1;
    end
    return r;
  endfunction

  // d8 — NEGATIVE: a DIFFERENT name is selected
  function int d8_othername (int unsigned s);
    bit [31:0] v, w; v = 1;
    if (s) begin
      v ^= 3;                    // cell d8r
      w[0] = 1;
    end
    return v + w;
  endfunction

  // d9 — the reference is the function's own RETURN NAME, select on a local
  function int unsigned d9_mix (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      d9_mix ^= 3;               // cell d9r
      v[0] = 1;
    end
  endfunction

  // d10 — reference inside a nested SUBROUTINE CALL statement argument
  function int d10_callstmt (int unsigned s);
    bit [31:0] v; int r; v = 1;
    if (s) begin
      r = helper122(v + 1);
      v[0] = 1;
    end
    return r;
  endfunction
endpackage
