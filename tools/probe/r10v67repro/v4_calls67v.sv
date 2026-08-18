// r10v67 verifier arm 4 — the CALL-ARGUMENT fence pushed to every mixed
// nesting the `callArgDepth - sysCallArgDepth22 == 0` spelling can meet:
//   user(sys(x))   sys(user(x))   sys(sys(x))   user(user(x))
//   a DIRECT bit-select argument (not wrapped in a concat)
//   a method call on a class handle / a package-qualified call
//   a system call whose argument is the INDEX itself
//   $bits/$size/$clog2 (compile-time system functions)
// and a distance-0 twin of each, which must never move.
package v4pkg67;
  function automatic logic qf(input logic [15:0] v);
    return ^v;
  endfunction
endpackage

module v4_calls67 (input logic [15:0] d, output logic [15:0] y);
  logic [15:0] w;
  assign w = d;
  function automatic logic uf(input logic [15:0] v);
    return ^v;
  endfunction
  function automatic logic uf2(input logic a, input logic b);
    return a ^ b;
  endfunction

  for (genvar g = 0; g < 2; g++) begin : qA
    localparam int unsigned Ku = g + 1;
    // distance-0 twins: must never move
    logic z_out, z_us, z_su, z_ss, z_uu, z_dir;
    assign z_out = w[Ku];
    assign z_us  = uf({15'b0, $signed({15'b0, w[Ku]})});
    assign z_su  = ^($signed({15'b0, uf({15'b0, w[Ku]})}));
    assign z_ss  = ^($signed($unsigned({15'b0, w[Ku]})));
    assign z_uu  = uf({15'b0, uf({15'b0, w[Ku]})});
    assign z_dir = uf2(w[Ku], 1'b0);
    if (1) begin : qB
      logic o_out, o_us, o_su, o_ss, o_uu, o_dir, o_q, o_clog, o_bits;
      assign o_out  = w[Ku];                                   // folds
      assign o_us   = uf({15'b0, $signed({15'b0, w[Ku]})});    // USER(SYS(x))
      assign o_su   = ^($signed({15'b0, uf({15'b0, w[Ku]})})); // SYS(USER(x))
      assign o_ss   = ^($signed($unsigned({15'b0, w[Ku]})));   // SYS(SYS(x))
      assign o_uu   = uf({15'b0, uf({15'b0, w[Ku]})});         // USER(USER(x))
      assign o_dir  = uf2(w[Ku], 1'b0);                        // DIRECT arg
      assign o_q    = v4pkg67::qf({15'b0, w[Ku]});             // QUALIFIED
      assign o_clog = w[$clog2(4)] ^ w[Ku];
      assign o_bits = |($bits(w) > 0 ? {15'b0, w[Ku]} : 16'b0);
      assign y[g]   = o_out^o_us^o_su^o_ss^o_uu^o_dir^o_q^o_clog^o_bits^
                      z_out^z_us^z_su^z_ss^z_uu^z_dir;
    end
  end
  assign y[15:2] = '0;
endmodule
