// r10earl3 w.sv — § pkgFuncFillSizedInElab residues: does the ARGUMENT-LESS
// package function still take the sizing, and does an assignment to a MODULE
// VARIABLE (rather than a net) still count as the continuous assignment?
package wp;
  // A: no args, cont-assign rhs, LHS of the assign is a module VARIABLE
  function automatic logic [7:0] wf_noarg();
    logic [7:0] a; a = '0; return a;
  endfunction
  // B: one arg, cont-assign rhs, LHS is a module VARIABLE
  function automatic logic [7:0] wf_arg(logic [7:0] x);
    logic [7:0] b; b = '0; return b ^ x;
  endfunction
  // C: one arg, cont-assign rhs, LHS is an output NET
  function automatic logic [7:0] wf_net(logic [7:0] x);
    logic [7:0] c; c = '0; return c ^ x;
  endfunction
  // D: `'1` instead of `'0`, one arg, cont-assign rhs onto a net
  function automatic logic [7:0] wf_ones(logic [7:0] x);
    logic [7:0] d; d = '1; return d ^ x;
  endfunction
  // E: `'x`, same
  function automatic logic [7:0] wf_x(logic [7:0] x);
    logic [7:0] e; e = 'x; return e ^ x;
  endfunction
  // F: LHS is a BIT SELECT of the variable, not the whole variable
  function automatic logic [7:0] wf_sel(logic [7:0] x);
    logic [7:0] f; f = x; f[0] = '1; return f;
  endfunction
  // G: 128-bit multi-dim return, NO args (the v.sv vf_128 shape)
  function automatic logic [3:0][3:0][7:0] wf_128();
    logic [3:0][3:0][7:0] g; g = '0; return g;
  endfunction
  // H: `return '1;` — a package function that IS a cont-assign's direct rhs
  function automatic logic [7:0] wf_reth(logic [7:0] x);
    if (x[0]) return '1; return x;
  endfunction
  // I: `return '1;` — a package function reached only under an operation
  function automatic logic [7:0] wf_reti(logic [7:0] x);
    if (x[0]) return '1; return x;
  endfunction
endpackage

module wm (input logic [7:0] i, output logic [7:0] oc, output logic [7:0] od,
           output logic [7:0] oe, output logic [7:0] of);
  logic [7:0] va, vb;
  assign va = wp::wf_noarg();
  assign vb = wp::wf_arg(i);
  assign oc = wp::wf_net(i);
  assign od = wp::wf_ones(i);
  assign oe = wp::wf_x(i);
  assign of = wp::wf_sel(i);
  logic [3:0][3:0][7:0] v128;
  assign v128 = wp::wf_128();
  logic [7:0] vh, vi;
  assign vh = wp::wf_reth(i);          // DIRECT cont-assign rhs
  assign vi = wp::wf_reti(i) ^ 8'h1;   // under an operation
  // keep va/vb observable
  logic [7:0] unusedsink;
  assign unusedsink = va ^ vb ^ v128[0][0] ^ vh ^ vi;
endmodule
