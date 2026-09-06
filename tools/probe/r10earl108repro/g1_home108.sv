// r10earl108 g1 — THE CORPUS SHAPE, reduced.
// Earlgrey pwrmgr_cdc.sv:106-110 instantiates prim_flop_2sync with
//   .ResetValue(PWR_AST_RSP_SYNC_DEFAULT)
// where the FORMAL is `parameter bit ResetValue = 0` (a ONE-BIT non-struct)
// and the ACTUAL is a wildcard-imported PACKED-STRUCT package parameter whose
// own initializer is an assignment pattern.
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole judge.
package p108;
  typedef struct packed {
    logic [1:0] slow_clk_val;
    logic [1:0] core_clk_val;
    logic [1:0] io_clk_val;
    logic       main_pok;
  } rsp_t;

  parameter rsp_t RSP_SYNC_DEFAULT = '{
    slow_clk_val: 2'b01,
    core_clk_val: 2'b01,
    io_clk_val: 2'b10,
    main_pok: 1'b0
  };
endpackage

module child108 #(
  parameter int Width      = 16,
  parameter bit ResetValue = 0
) (
  input                    clk_i,
  input        [Width-1:0] d,
  output logic [Width-1:0] q
);
  always_ff @(posedge clk_i) q <= d ^ {Width{ResetValue}};
endmodule

module g1_home108
  import p108::*;
(
  input        clk_i,
  input  rsp_t ast_i,
  output rsp_t ast_o
);
  child108 #(
    .Width($bits(rsp_t)),
    .ResetValue(RSP_SYNC_DEFAULT)
  ) i_sync (
    .clk_i (clk_i),
    .d     (ast_i),
    .q     (ast_o)
  );
endmodule
