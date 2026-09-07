// r10earl119 a1_def119 — THE DEFAULT-VIEW AXES r10earl106's own arms do not
// vary: the comma list, the NET target, the implicit net, `time`, the
// unsized-`'1` operand, an interface nested in a module, generate depth, a
// for-generate with several unrollings, and the NAMESAKE shadow that
// r10earl118's fence exists for.  Every row is a gen-scope continuous assign
// whose Rhs is a WRITTEN cast; the discriminator is what the target is.
// MEASUREMENT ONLY.
package pa1_119;
  parameter int unsigned W8 = 8;
endpackage

interface ifa_119;
  logic [7:0] if_v;                 // interface home: bindVariable stops dead
  if (1) begin : gen_ifa
    assign if_v = pa1_119::W8'(6'h3F);
  end
endinterface

module cha_119 (output logic [7:0] o);
  logic [7:0] ch_v;                 // CHILD instance, module-body target
  if (1) begin : gen_ch
    assign ch_v = pa1_119::W8'(6'h3F);
  end
  assign o = ch_v;
endmodule

module a1_def119 (output logic [7:0] o1, output logic [7:0] o2);
  logic [7:0]  d_a, d_b;            // the COMMA LIST pair (different widths
  logic [3:0]  d_c;                 //   so one key cannot serve the other)
  wire  [7:0]  n_w;                 // a declared NET target
  wire  [7:0]  d_loop;            // a NET: three loop unrollings may all
                                    //   drive it (a variable may not)
  logic [7:0]  d_deep;
  logic [7:0]  d_ns;                // the module-body NAMESAKE
  time         d_time;              // r10v106's `time` exclusion
  logic [7:0]  d_ub;                // the `'1` operand (ExprEval `resize`)
  logic [7:0]  d_scal;
  logic        d_bit;               // 1-bit target: the mask must bite

  // A: the HEAD SHAPE — module-body target, gen-IF, constant operand.
  if (1) begin : gen_a
    assign d_a = pa1_119::W8'(6'h3F);
  end

  // B: a COMMA LIST inside one gen scope.  Both members bind, to targets of
  //    DIFFERENT widths, so a key that cannot tell them apart is visible.
  if (1) begin : gen_b
    assign d_b = pa1_119::W8'(6'h3F), d_c = pa1_119::W8'(6'h3F);
  end

  // C: a declared NET target (a `wire`, not a var).
  if (1) begin : gen_c
    assign n_w = pa1_119::W8'(6'h3F);
  end

  // D: an IMPLICIT net target — no declaration, so no typespec to size with.
  if (1) begin : gen_d
    assign imp_n = pa1_119::W8'(6'h3F);
  end

  // E: a GEN-LOCAL target — bindVariable never sees it.
  if (1) begin : gen_e
    logic [7:0] loc_e;
    assign loc_e = pa1_119::W8'(6'h3F);
  end

  // F: the NAMESAKE — the same name declared in the module body AND locally.
  if (1) begin : gen_f
    logic [3:0] d_ns;
    assign d_ns = pa1_119::W8'(6'h3F);
  end

  // G: a for-generate with THREE unrollings of ONE written span, onto a
  //    module-body NET (three continuous drivers of a net are legal SV; three
  //    of a variable are not, which is why this row's target is a wire).
  for (genvar i = 0; i < 3; i++) begin : gen_g
    assign d_loop = pa1_119::W8'(6'h3F);
  end

  // H: generate DEPTH 3.
  if (1) begin : gen_h1
    if (1) begin : gen_h2
      if (1) begin : gen_h3
        assign d_deep = pa1_119::W8'(6'h3F);
      end
    end
  end

  // I: a `time` target (64-bit integral, but Surelog's time_var carries a
  //    typespec `adjustSize` does not size).
  if (1) begin : gen_i
    assign d_time = pa1_119::W8'(6'h3F);
  end

  // J: an UNSIZED all-ones operand — ExprEval's `resize` MUTATES it in place.
  if (1) begin : gen_j
    assign d_ub = pa1_119::W8'('1);
  end

  // K: a SCALAR (1-bit) target: the adjust must mask 63 down to 1.
  if (1) begin : gen_k
    assign d_bit = pa1_119::W8'(6'h3F);
  end

  // L: a plain scalar-width `logic [7:0]` target assigned a WIDER cast.
  if (1) begin : gen_l
    assign d_scal = 64'(64'hFFFF_FFFF_FFFF_FFFF);
  end

  cha_119 u_ch (.o(o1));
  ifa_119 u_if ();
  // (`imp_n` is minted INSIDE gen_d by the assignment itself and is not
  // visible here — reading it at module level is a compile error on both
  // tools, which is itself the proof that the implicit net is gen-scope local.)
  assign o2 = d_a ^ d_b ^ d_loop ^ d_deep ^ d_ns ^ d_ub ^ n_w;
endmodule
