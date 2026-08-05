// r10earl6 pp.sv — the BIGGEST remaining Earlgrey class: 11 AllModules heads
// (+2 TopPackages) reading
//     failLhs <null>   failRhs ref_typespec '' :0:0
//     ^ operation '' :61:32
//     ^ func_call 'aes_mul_gf2p2' :61:18
//     ^ assignment '' :61:5
//     ^ begin / function 'aes_mul_gf2p4' :57:3
//     ^ package 'aes_sbox_canright_pkg'
// i.e. WE emit a Typespec ref on a func-call ARGUMENT that golden leaves
// bare.  aes_sbox_canright_pkg.sv:61 is
//     b = aes_mul_gf2p2(gamma[3:2] ^ gamma[1:0], delta[3:2] ^ delta[1:0]);
// inside `function automatic logic [3:0] aes_mul_gf2p4(logic [3:0] gamma,
// logic [3:0] delta)`, and 61:32 is the SECOND argument's `^` operation.
// Ranked (1) in the pass-3 README and (3) in pass 4's; v.sv/w.sv carried it
// as a residue but never isolated it.
package pp;

  // the callee: two 2-bit args, exactly aes_mul_gf2p2's shape
  function automatic logic [1:0] pf2(logic [1:0] x, logic [1:0] y);
    logic [1:0] r;
    r = x & y;
    return r;
  endfunction

  function automatic logic [1:0] pf1(logic [1:0] x);
    return ~x;
  endfunction

  function automatic logic [3:0] pf4(logic [3:0] gamma, logic [3:0] delta);
    logic [3:0] theta;
    logic [1:0] a, b, c;
    // row A — PLAIN part-select args (no operation): golden and we agree
    a          = pf2(gamma[3:2], delta[3:2]);
    // row B — the aes shape: BOTH args are `^` operations
    b          = pf2(gamma[3:2] ^ gamma[1:0], delta[3:2] ^ delta[1:0]);
    // row C — ONE operation arg, one plain
    c          = pf2(gamma[1:0] ^ delta[1:0], delta[1:0]);
    // row D — a single-arg call with an operation arg
    theta[3:2] = a ^ pf1(b);
    theta[1:0] = c ^ pf1(b ^ a);
    return theta;
  endfunction

endpackage

module pchild (input logic [3:0] i, output logic [3:0] o);
  // rows E..H — the SAME shapes in a MODULE-LOCAL function.  FuncArgs (the
  // witness the stamp was measured on) is a module function whose RECURSIVE
  // self-call carries `exp - 1`, so "module vs package" is the first
  // candidate distinguisher and this half pins it.
  function automatic logic [1:0] mf2(logic [1:0] x, logic [1:0] y);
    logic [1:0] r;
    r = x & y;
    return r;
  endfunction
  function automatic logic [3:0] mf4(logic [3:0] gamma, logic [3:0] delta);
    logic [3:0] theta;
    logic [1:0] a, b, c;
    a          = mf2(gamma[3:2], delta[3:2]);
    b          = mf2(gamma[3:2] ^ gamma[1:0], delta[3:2] ^ delta[1:0]);
    c          = mf2(gamma[1:0] ^ delta[1:0], delta[1:0]);
    theta[3:2] = a ^ b;
    theta[1:0] = c ^ a;
    return theta;
  endfunction
  // row I — the FuncArgs shape itself: a RECURSIVE module function with an
  // arithmetic argument (the one golden DOES stamp)
  function automatic logic [3:0] pow_m(logic [3:0] base, logic [3:0] exp);
    logic [3:0] r;
    r = 1;
    if (exp > 0)
      r = base * pow_m(base, exp - 1);
    return r;
  endfunction
  assign o = pp::pf4(i, ~i) ^ mf4(i, ~i) ^ pow_m(i, 4'd3);
endmodule

module pp_top (input logic [3:0] i, output logic [3:0] o);
  pchild u_p (.i(i), .o(o));
endmodule
