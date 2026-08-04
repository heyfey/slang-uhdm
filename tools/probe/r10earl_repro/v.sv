// r10earl3 v.sv — DISTINGUISHER MATRIX for § calledFuncFillSized (u.sv).
// Each row is a fill literal in a CALLED subroutine body; read the TOP
// (uhdmtopPackages / uhdmtopModules) view size.
package vp;

  // 1  '0 at a 128-bit multi-dim var   (the aes_pkg shape)
  function automatic logic [3:0][3:0][7:0] vf_128();
    logic [3:0][3:0][7:0] a; a = '0; return a;
  endfunction

  // 2  '1 at 8 bits
  function automatic logic [7:0] vf_ones();
    logic [7:0] b; b = '1; return b;
  endfunction

  // 3  'x at 8 bits
  function automatic logic [7:0] vf_x();
    logic [7:0] c; c = 'x; return c;
  endfunction

  // 4  'z at 8 bits
  function automatic logic [7:0] vf_z();
    logic [7:0] d; d = 'z; return d;
  endfunction

  // 5  '0 into an `int` (a non-vector integral type)
  function automatic int vf_int();
    int e; e = '0; return e;
  endfunction

  // 6  '0 as a DECLARATION INITIALIZER rather than an assignment statement
  function automatic logic [7:0] vf_declinit();
    logic [7:0] f = '0; return f;
  endfunction

  // 7  '0 as a RETURN expression (no LHS variable)
  function automatic logic [7:0] vf_ret();
    return '0;
  endfunction

  // 8  '0 as an OPERAND of a binary op
  function automatic logic [7:0] vf_operand(logic [7:0] i0);
    logic [7:0] g; g = i0 | '0; return g;
  endfunction

  // 9  '0 assigned to a var, in a TASK not a function
  task automatic vt_task(output logic [15:0] o16);
    logic [15:0] h; h = '0; o16 = h;
  endtask

  // 10 a based literal beside it (control: never a fill)
  function automatic logic [7:0] vf_based();
    logic [7:0] k; k = 8'h0; return k;
  endfunction

endpackage

module vm (input logic [7:0] i, output logic [7:0] o, output logic [15:0] o16);
  // 11 a MODULE-LOCAL called function with the same shape
  function automatic logic [7:0] vmf();
    logic [7:0] m; m = '0; return m;
  endfunction
  // 12 an always_comb body fill (not a subroutine at all)
  logic [7:0] r;
  always_comb begin
    r = '0;
  end
  logic [15:0] tk;
  always_comb begin
    vp::vt_task(tk);
  end
  assign o16 = tk;
  logic [3:0][3:0][7:0] w128;
  int                   wint;
  assign w128 = vp::vf_128();
  assign wint = vp::vf_int();
  assign o = vp::vf_ones() ^ vp::vf_x() ^ vp::vf_z() ^
             vp::vf_declinit() ^ vp::vf_ret() ^
             vp::vf_operand(i) ^ vp::vf_based() ^ vmf() ^ r;
endmodule
