// wa24.sv — pass-24 residue (1): the FOLD-vs-KEEP law at
// ibex_cs_registers.sv:795:44.  Corpus shape:
//     if (PMPEnable) begin : g_pmp_registers
//       for (genvar i = 0; i < PMPNumRegions; i++) begin : g_pmp_csrs
//         assign pmp_cfg_we[i] = csr_we_int & ~pmp_cfg[i].lock &
//                                (csr_addr == (CSR_OFF_PMP_CFG + (i[11:0] >> 2)));
// where CSR_OFF_PMP_CFG is a WILDCARD-IMPORTED PACKAGE parameter
// (`parameter logic [11:0] ... = 12'h3A0`).  Golden KEEPS a bound ref_obj; we
// FOLD to `constant {ct=5 sz=12 dec=12'h3A0}`.
//
// The 2x2 this file measures, all inside a CHILD instance (the pass-23
// child-instance trap): { for-gen NESTED in an if-gen | FLAT module-level
// for-gen } x { package param | module localparam }, plus a module-level
// (non-gen) control row and a plain-operand row without the select/shift.
package p24;
  parameter logic [11:0] K_CFG  = 12'h3A0;
  parameter logic [11:0] K_ADDR = 12'h3B0;
  parameter int unsigned NREG   = 4;
endpackage

module ch24
  import p24::*;
#(
  parameter bit En = 1'b1,
  parameter int unsigned NR = 4
) (
  input  logic [11:0] addr,
  input  logic        we,
  output logic [3:0]  n_we,      // NESTED for-gen inside if-gen, pkg param
  output logic [3:0]  f_we,      // FLAT for-gen, pkg param
  output logic [3:0]  n_lp,      // NESTED, module localparam
  output logic [3:0]  f_lp,      // FLAT, module localparam
  output logic        m_we,      // module-level CA control, pkg param
  output logic [3:0]  n_bare     // NESTED, pkg param as a PLAIN operand
);
  localparam logic [11:0] L_CFG = 12'h2A0;

  // ---- NESTED: for-generate inside an if-generate (the corpus shape) ----
  if (En) begin : g_regs
    logic [NR-1:0] loc_we;
    logic [NR-1:0] loc_lp;
    logic [NR-1:0] loc_bare;
    for (genvar i = 0; i < NR; i++) begin : g_csrs
      assign loc_we[i]   = we & (addr == (K_CFG + (i[11:0] >> 2)));
      assign loc_lp[i]   = we & (addr == (L_CFG + (i[11:0] >> 2)));
      assign loc_bare[i] = we & (addr == K_ADDR);
    end
    assign n_we   = loc_we;
    assign n_lp   = loc_lp;
    assign n_bare = loc_bare;
  end

  // ---- FLAT: for-generate directly in the module body ----
  logic [3:0] fl_we, fl_lp;
  for (genvar j = 0; j < 4; j++) begin : g_flat
    assign fl_we[j] = we & (addr == (K_CFG + (j[11:0] >> 2)));
    assign fl_lp[j] = we & (addr == (L_CFG + (j[11:0] >> 2)));
  end
  assign f_we = fl_we;
  assign f_lp = fl_lp;

  // ---- module-level control ----
  assign m_we = we & (addr == (K_CFG + 12'd1));
endmodule

module wa24 (
  input  logic [11:0] addr,
  input  logic        we,
  output logic [3:0]  a, b, c, d, e,
  output logic        f
);
  ch24 #(.En(1'b1), .NR(4)) u_c (
    .addr(addr), .we(we),
    .n_we(a), .f_we(b), .n_lp(c), .f_lp(d), .m_we(f), .n_bare(e)
  );
endmodule
