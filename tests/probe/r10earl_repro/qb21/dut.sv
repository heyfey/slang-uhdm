// qb21.sv — PASS 21 witness.  After § elabConnSelFoldNoTs21 landed, the
// top_earlgrey bisect advanced from `if_stage_i > port instr_pmp_err_i` down
// to
//   work@top_earlgrey > u_rv_core_ibex > u_core > if_stage_i
//     > gen_scope_array gen_prefetch_buffer > gen_scope
//       > module_inst prefetch_buffer_i > cont_assign :127:10
//         > operation op=28 > operation op=4
//           > bit_select 'rdata_outstanding_q' :128:47 > vpiIndex
// where golden keeps an `operation {op=11}` (vpiSubOp, 2 operands) and we
// fold to `constant {ct=9 sz=64 dec=1}`.
//   ibex_prefetch_buffer.sv:128:47  `~rdata_outstanding_q[NUM_REQS-1]`
// with `localparam int unsigned NUM_REQS = 2;` MODULE-LOCAL.
//
// The 2x2 separates the two candidate features:
//   * instantiation context: plain child vs child inside a for-generate
//   * index expression: `NUM_REQS-1` (arithmetic on a module localparam) vs
//     a bare `NUM_REQS` read and a literal.
module qb21_child (
    input  logic [3:0] q,
    output logic       y1,
    output logic       y2,
    output logic       y3
);
  localparam int unsigned NUM_REQS = 2;
  assign y1 = ~q[NUM_REQS-1];   // R1 arithmetic over a module localparam
  assign y2 = ~q[NUM_REQS];     // R2 bare localparam read
  assign y3 = ~q[1];            // R3 literal
endmodule

module qb21 (
    input  logic [3:0] q,
    output logic [2:0] a,
    output logic [2:0] b
);
  qb21_child u_plain (.q(q), .y1(a[0]), .y2(a[1]), .y3(a[2]));

  for (genvar g = 0; g < 1; g++) begin : gen_b
    qb21_child u_gen (.q(q), .y1(b[0]), .y2(b[1]), .y3(b[2]));
  end
endmodule
