// r10uvm122 arm c — the SCOPE face: where the select sits relative to the
// reference, and which block declares the name.
package p122c;
  // c1 — select and reference in the SAME block as the DECLARATION
  function int c1_decl_same (int unsigned s);
    bit [31:0] v;
    v ^= 3;                       // cell c1r
    v[0] = 1;
    return v;
  endfunction

  // c2 — reference is ONE CONTROL BODY DEEPER than the select's block
  function int c2_deeper (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      if (s) v ^= 3;              // cell c2r
      v[0] = 1;
    end
    return v;
  endfunction

  // c3 — the select is NOT a direct statement of the block
  function int c3_notdirect (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      v ^= 3;                     // cell c3r
      if (s) v[0] = 1;
    end
    return v;
  endfunction

  // c4 — the select is in an INNER block, the reference OUTSIDE it
  function int c4_selinner (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      begin v[0] = 1; end
      v ^= 3;                     // cell c4r
    end
    return v;
  endfunction

  // c5 — a NESTED declaration between the reference and the select
  function int c5_innerdecl (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      v[0] = 1;
      begin
        bit [31:0] v;
        v ^= 3;                   // cell c5r  (a SHADOWING local)
      end
    end
    return v;
  endfunction

  // c6 — a NAMED begin
  function int c6_named (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin : nb122
      v ^= 3;                     // cell c6r
      v[0] = 1;
    end
    return v;
  endfunction

  // c7 — a FOR-loop body block
  function int c7_for (int unsigned s);
    bit [31:0] v; v = 1;
    for (int i = 0; i < 2; i++) begin
      v ^= 3;                     // cell c7r
      v[0] = 1;
    end
    return v;
  endfunction

  // c8 — a WHILE body block
  function int c8_while (int unsigned s);
    bit [31:0] v; v = 1;
    while (s) begin
      v ^= 3;                     // cell c8r
      v[0] = 1;
    end
    return v;
  endfunction

  // c9 — a CASE arm block
  function int c9_case (int unsigned s);
    bit [31:0] v; v = 1;
    case (s)
      0: begin
        v ^= 3;                   // cell c9r
        v[0] = 1;
      end
      default: v = 2;
    endcase
    return v;
  endfunction

  // c10 — a FORK..JOIN block
  task c10_fork (int unsigned s);
    bit [31:0] v; v = 1;
    fork
      v ^= 3;                     // cell c10r
      v[0] = 1;
    join
  endtask

  // c11 — TWO levels out: the select sits in the FUNCTION-BODY block, the
  //       reference two control bodies deeper
  function int c11_twoout (int unsigned s);
    bit [31:0] v;
    v[0] = 1;
    if (s) begin
      if (s) begin
        v ^= 3;                   // cell c11r
      end
    end
    return v;
  endfunction

  // c12 — the DECLARING block ALSO holds the select, the reference deeper
  function int c12_declsel (int unsigned s);
    bit [31:0] v; v = 1;
    if (s) begin
      bit [31:0] w;
      w[0] = 1;
      if (s) begin
        w ^= 3;                   // cell c12r
      end
      v = w;
    end
    return v;
  endfunction
endpackage
