// qh21.sv — PASS 21.  Next top_earlgrey residue after the two gen-loop laws:
//   work@top_earlgrey > u_rv_core_ibex > u_core > id_stage_i
//     > gen_scope_array gen_stall_mem > gen_scope
//       > cont_assign ibex_id_stage.sv:911:12 > operation {op=32}
//         > ref_obj 'WB_INSTR_OTHER' :911:45 > vpiActual
// golden <null>, ours enum_const.  The read is a WILDCARD-IMPORTED package
// ENUM CONSTANT inside an IF-generate gen scope's cont_assign RHS ternary, in
// a module that is itself a CHILD instance.
//   assign instr_type_wb_o = ~lsu_req_dec ? WB_INSTR_OTHER : ...
// Rows: enum const vs plain package parameter, if-gen vs for-gen, child
// instance vs top module.
package qh21_pkg;
  typedef enum logic [1:0] {
    E_A = 2'd0,
    E_B = 2'd1,
    E_C = 2'd2
  } e_t;
  parameter int unsigned PW = 1;
endpackage

module qh21_child
  import qh21_pkg::*;
(
    input  logic c,
    output e_t   o1,
    output e_t   o2,
    output logic [1:0] o3,
    output e_t   o4
);
  assign o4 = c ? E_A : E_B;            // R5 MODULE-LEVEL control row
  if (1) begin : gen_if
    assign o1 = c ? E_A : E_B;          // R1 enum const, IF-generate
    assign o3 = c ? PW : 2'd3;          // R3 pkg parameter, IF-generate
  end
  for (genvar g = 0; g < 1; g++) begin : gen_for
    assign o2 = c ? E_A : E_C;          // R2 enum const, FOR-generate
  end
endmodule

module qh21
  import qh21_pkg::*;
(
    input  logic c,
    output e_t   a1,
    output e_t   a2,
    output logic [1:0] a3,
    output e_t   a4,
    output e_t   b1
);
  qh21_child u_c (.c(c), .o1(a1), .o2(a2), .o3(a3), .o4(a4));

  if (1) begin : gen_top
    assign b1 = c ? E_A : E_B;          // R4 the same read in the TOP module
  end
endmodule
