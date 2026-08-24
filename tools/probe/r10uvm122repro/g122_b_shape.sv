// r10uvm122 arm b — the SELECT-SHAPE face.  The reference is always a bare
// name in the same inner begin; only the WRITTEN LVALUE changes.
package p122b;
  class k122b;
    bit [31:0] f;
  endclass

  // b1 — literal bit index
  function int b1_lit (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; v[0] = 1; end
    return v;
  endfunction

  // b2 — VARIABLE bit index
  function int b2_var (int unsigned s, int i);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; v[i] = 1; end
    return v;
  endfunction

  // b3 — constant part-select
  function int b3_part (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; v[3:0] = 4'h1; end
    return v;
  endfunction

  // b4 — ascending indexed part-select
  function int b4_ipsup (int unsigned s, int i);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; v[i+:4] = 4'h1; end
    return v;
  endfunction

  // b5 — descending indexed part-select
  function int b5_ipsdn (int unsigned s, int i);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; v[i-:4] = 4'h1; end
    return v;
  endfunction

  // b6 — TWO-DIMENSIONAL packed select
  function int b6_twodim (int unsigned s);
    bit [3:0][7:0] v; v = 0;
    if (s) begin v ^= 3; v[0][1] = 1; end
    return v[1];
  endfunction

  // b7 — the select is inside a CONCATENATION lvalue
  function int b7_concat (int unsigned s);
    bit [31:0] v; bit x; v = 1;
    if (s) begin v ^= 3; {x, v[0]} = 2'b11; end
    return v;
  endfunction

  // b8 — an UNPACKED-array element write
  function int b8_unpk (int unsigned s);
    int v [0:3];
    if (s) begin v = '{default:0}; v[0] = 1; end
    return v[1];
  endfunction

  // b9 — the write is a member select of a class handle (hier_path lvalue)
  function int b9_member (int unsigned s, k122b h);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; h.f[0] = 1; end
    return v;
  endfunction

  // b10 — the write is NONBLOCKING
  task b10_nb (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; v[0] <= 1; end
  endtask

  // b11 — TWO selects of the same name; Surelog takes the FIRST in stmt order
  function int b11_two (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin v ^= 3; v[5:4] = 2'h1; v[0] = 1; end
    return v;
  endfunction

  // b12 — a whole write SITS BEFORE the select (Surelog skips ref_obj lhs)
  function int b12_whole1st (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin v = 7; v[0] = 1; v ^= 3; end
    return v;
  endfunction
endpackage
