// wd24.sv — pass-24 residue (1), the SELECT-POSITION half of
// § genNestedScopePkgParamNoFold24.  The law's first cut excluded every select
// position, and the corpus bisect immediately advanced to
// ibex_cs_registers.sv:798:59 — `assign pmp_cfg_wdata[i].lock =
// csr_wdata_int[(i%4)*PMP_CFG_W+7];`, a bit-select INDEX OPERATION where
// golden ALSO keeps the ref bound to a fresh enum_const.  This measures every
// select spelling in one nested gen scope so the exclusion can be written from
// data instead of caution.
package s24;
  parameter int unsigned S_W  = 8;
  parameter int unsigned S_LO = 2;
  parameter int unsigned S_HI = 5;
  parameter int unsigned S_B  = 3;
  parameter int unsigned S_P  = 4;
  parameter int unsigned S_Q  = 6;
endpackage

module cd24
  import s24::*;
#(
  parameter bit En = 1'b1
) (
  input  logic [31:0] dat,
  output logic        o_idxop, o_idx,
  output logic [3:0]  o_ps,
  output logic [1:0]  o_ips,
  output logic        o_plain
);
  if (En) begin : g_o
    logic       r_idxop, r_idx, r_plain;
    logic [3:0] r_ps;
    logic [1:0] r_ips;
    for (genvar i = 0; i < 1; i++) begin : g_i
      // R1: bit-select INDEX written as an OPERATION (the corpus shape)
      assign r_idxop = dat[(i % 4) * S_W + 7];
      // R2: BARE bit-select index
      assign r_idx   = dat[S_B];
      // R3: PART-select bounds
      assign r_ps    = dat[S_HI:S_LO];
      // R4: INDEXED part-select base
      assign r_ips   = dat[S_P+:2];
      // R5: plain operand control (known KEEP)
      assign r_plain = dat[0] & (S_Q > 3);
    end
    assign o_idxop = r_idxop;
    assign o_idx   = r_idx;
    assign o_ps    = r_ps;
    assign o_ips   = r_ips;
    assign o_plain = r_plain;
  end
endmodule

module wd24 (
  input  logic [31:0] dat,
  output logic        a, b, e,
  output logic [3:0]  c,
  output logic [1:0]  d
);
  cd24 #(.En(1'b1)) u_c (.dat(dat), .o_idxop(a), .o_idx(b), .o_ps(c),
                         .o_ips(d), .o_plain(e));
endmodule
