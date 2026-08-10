// qb23 — THE UNMEASURED QUARTER of pass 22's § genCaEnumBindsSelectOnly22.
// That law says a gen-scope cont-assign RHS binds an enum const ONLY in a
// select position or under a SELECT LHS.  Every qa22 row assigned a module
// OUTPUT PORT, so the GEN-LOCAL-LHS quarter was never measured — and the
// whole-arena bind census over Earlgrey names two corpus rows where golden
// binds and we do not, both with a gen-scope-local LHS:
//   ibex_wb_stage.sv:77   assign wb_done =
//                           (wb_instr_type_q == WB_INSTR_OTHER) | lsu_resp_valid_i;
//   ibex_cs_registers.sv:993 assign tmatch_control_we =
//                           csr_we_int & debug_mode_i & (csr_addr_i == CSR_TDATA1);
// Rows here: L* = gen-LOCAL LHS, P* = module-PORT LHS control (qa22's shape),
// A* = a NESTED gen scope assigning an ANCESTOR gen scope's local, and
// M* = a MODULE-LOCAL typedef enum (the tlul_adapter_sram OpRead/OpWrite
// family: 40 refs in the census, module-level cont_assigns, golden binds).
package qb23_pkg;
  typedef enum logic [1:0] { K_A = 2'd0, K_B = 2'd1, K_C = 2'd2 } k_t;
endpackage

module qb23_child
  import qb23_pkg::*;
(
    input  logic       c,
    input  k_t         s,
    input  logic [7:0] w,
    output logic       p1,
    output logic       p2,
    output k_t         p3,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       m1,
    output logic       m2
);
  // A MODULE-LOCAL typedef enum — tlul_adapter_sram's req_op_e.
  typedef enum logic [1:0] { OpW, OpR, OpU } op_e;
  op_e mop;

  // M1/M2 — module-level cont_assigns over the MODULE-LOCAL enum, the
  // tlul_adapter_sram shape (:219 comparison; :202 ternary arms).
  assign m1 = (mop == OpR) ? 1'b1 : 1'b0;
  assign m2 = (mop != OpW);

  // P1..P3 — qa22's controls re-stated: PORT LHS, package enum.  Golden
  // leaves all of these UNBOUND inside a gen scope.
  if (1) begin : gen_port
    assign p1 = (s == K_B);
    assign p2 = c ? 1'b1 : 1'b0;
    assign p3 = c ? K_A : K_B;
  end

  // L1..L5 — the SAME shapes with a GEN-LOCAL LHS.
  if (1) begin : gen_local
    logic       l_cmp;
    logic       l_and;
    k_t         l_tern;
    k_t         l_bare;
    logic [1:0] l_op;

    assign l_cmp  = (s == K_B);                 // comparison, gen-local LHS
    assign l_and  = c & (s == K_C);             // comparison under an AND
    assign l_tern = c ? K_A : K_B;              // ternary BRANCHES
    assign l_bare = K_C;                        // bare whole-RHS enum read
    assign l_op   = K_A | K_B;                  // plain bitwise operands

    assign o1 = l_cmp;
    assign o2 = l_and;
    assign o3 = (l_tern == K_A);
    assign o4 = (l_bare == K_C);
    assign o5 = l_op[0];
  end

  // A1 — a NESTED gen scope whose cont_assign LHS is an ANCESTOR gen scope's
  // local.  This is the half neither corpus row measures.
  if (1) begin : gen_outer
    logic a_outer;
    if (1) begin : gen_inner
      assign a_outer = (s == K_A);
    end
  end

  // A MODULE-LOCAL enum inside a gen scope, gen-local LHS: crosses the two
  // features.
  if (1) begin : gen_modenum
    logic g_mm;
    assign g_mm = (mop == OpU);
  end
endmodule

module qb23
  import qb23_pkg::*;
(
    input  logic       c,
    input  k_t         s,
    input  logic [7:0] w,
    output logic       p1,
    output logic       p2,
    output k_t         p3,
    output logic       o1,
    output logic       o2,
    output logic       o3,
    output logic       o4,
    output logic       o5,
    output logic       m1,
    output logic       m2
);
  qb23_child u_c (.c(c), .s(s), .w(w), .p1(p1), .p2(p2), .p3(p3),
                  .o1(o1), .o2(o2), .o3(o3), .o4(o4), .o5(o5),
                  .m1(m1), .m2(m2));
endmodule
