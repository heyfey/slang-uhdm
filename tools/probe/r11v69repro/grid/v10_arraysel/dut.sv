// v11u69 v10 — SELECT Lhs in a generate block (the landed Lhs fence) and the
// gen-local SHARE cells, both DECLINED by the patch.  These must be
// byte-identical pristine vs patched; golden folds them all, so they stay as
// pre-existing residues and MUST NOT get worse.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic a_i,
   output logic [31:0] o_bit, o_part,
   output logic [31:0] o_arr [0:1],
   output logic [31:0] o_own, o_anc, o_net);

  if (1) begin : gsel
    assign o_bit[0]    = CFG.n;    // bit-select Lhs   -> plainLhs=0
    assign o_part[7:0] = CFG.n;    // part-select Lhs  -> plainLhs=0
    assign o_arr[0]    = CFG.n;    // array-element    -> plainLhs=0
  end

  if (1) begin : gown
    logic [31:0] lv;               // own gen-local, no namesake -> genLocal=1
    assign lv = CFG.n;
    assign o_own = lv;
  end

  if (1) begin : ganc
    logic [31:0] av;
    if (1) begin : gi
      assign av = CFG.n;           // ancestor gen-local -> genLocal=1
    end
    assign o_anc = av;
  end

  if (1) begin : gnet
    wire [31:0] wv;                // gen-local NET -> genLocal=1
    assign wv = CFG.n;
    assign o_net = wv;
  end
endmodule
