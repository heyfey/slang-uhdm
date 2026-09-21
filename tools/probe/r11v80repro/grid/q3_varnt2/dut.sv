// v11u80 q3 -- LAW B's BOUNDARY.  § caImportedPkgDefNetTypeVar80 answers 0
// for ANY declaration carrying the `var` keyword.  z2_varnt asked var x the
// base keywords; this arm asks the SPELLINGS AROUND the qualifier that the
// same `modifiers` loop can see, and the ones it must NOT swallow:
// `static`/`automatic` lifetimes, `const` alone, a var-qualified typedef
// CHAIN, a var-qualified packed 2-D, a var-qualified signed vector, and the
// UNPACKED spellings of the same (whose def-view entry is a logic_net too).
package pq3;
  typedef logic [3:0] w_t;
  typedef w_t         w2_t;      // chain
  typedef reg   [3:0] r_t;
  typedef r_t         r2_t;      // chain

  // controls: unqualified
  logic [7:0]      c_log;
  reg   [7:0]      c_reg;
  w_t              c_tdw;
  r_t              c_tdr;
  logic signed [7:0] c_slog;

  // lifetimes without var -- MUST keep the keyword's answer
  static logic [7:0]    s_log;
  static reg   [7:0]    s_reg;

  // const without var -- MUST keep the keyword's answer (measured z2: 36)
  const logic [7:0]     k_log  = 8'd1;
  const reg   [7:0]     k_reg  = 8'd2;

  // var against the same
  var logic signed [7:0] v_slog;
  var w2_t               v_tdw2;   // var + CHAIN (chain alone already 0)
  var r2_t               v_tdr2;
  var logic [3:0][7:0]   v_pk2;    // var + packed 2-D
  var static logic [7:0] v_stlog;  // var AND static
  const var reg [7:0]    v_kreg = 8'd3;

  // the UNPACKED spellings: the def view lists these as logic_nets too
  logic [7:0]      c_ulog [0:1];
  reg   [7:0]      c_ureg [0:1];
  var logic [7:0]  v_ulog [0:1];
  var reg   [7:0]  v_ureg [0:1];
  w_t              c_utdw [0:1];
  var w_t          v_utdw [0:1];
  r_t              c_utdr [0:1];
  var r_t          v_utdr [0:1];
endpackage

module dut (output logic [31:0] o);
  import pq3::*;
  assign o = {24'd0, c_log} ^ {24'd0, c_reg} ^ {28'd0, c_tdw} ^ {28'd0, c_tdr}
           ^ {24'd0, c_slog} ^ {24'd0, s_log} ^ {24'd0, s_reg}
           ^ {24'd0, k_log} ^ {24'd0, k_reg}
           ^ {24'd0, v_slog} ^ {28'd0, v_tdw2} ^ {28'd0, v_tdr2}
           ^ v_pk2 ^ {24'd0, v_stlog} ^ {24'd0, v_kreg}
           ^ {24'd0, c_ulog[0]} ^ {24'd0, c_ureg[0]}
           ^ {24'd0, v_ulog[0]} ^ {24'd0, v_ureg[0]}
           ^ {28'd0, c_utdw[0]} ^ {28'd0, v_utdw[0]}
           ^ {28'd0, c_utdr[0]} ^ {28'd0, v_utdr[0]};
endmodule
