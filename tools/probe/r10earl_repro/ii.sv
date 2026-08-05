// r10earl5 ii.sv — residue (2): the pwrmgr/rstmgr package family.
// pwrmgr_pkg.sv:39 `parameter pwr_ast_rsp_t PWR_AST_RSP_DEFAULT = '{...}` —
// a STRUCT-TYPED package parameter whose initialiser is an ASSIGNMENT PATTERN.
// r10earl4pc localised the 6 AllPackages heads to pwrmgr_pkg TOP rows 5..12:
// "failLhs ref_typespec 0:0 / failRhs <null>" INSIDE the pattern operation.
package ip;

  parameter PowerDomains = 2;

  typedef struct packed {
    logic [1:0] slow_clk_val;
    logic [1:0] core_clk_val;
    logic [1:0] io_clk_val;
    logic       main_pok;
  } pwr_ast_rsp_t;

  // row A — named-field assignment pattern, the pwrmgr shape
  parameter pwr_ast_rsp_t RSP_DEFAULT = '{
    slow_clk_val: 2'b10,
    core_clk_val: 2'b10,
    io_clk_val: 2'b10,
    main_pok: 1'b1
  };

  // row B — the second one (pwrmgr has two)
  parameter pwr_ast_rsp_t RSP_SYNC_DEFAULT = '{
    slow_clk_val: 2'b01,
    core_clk_val: 2'b01,
    io_clk_val: 2'b10,
    main_pok: 1'b0
  };

  // row C — localparam spelling
  localparam pwr_ast_rsp_t RSP_LOCAL = '{
    slow_clk_val: 2'b11,
    core_clk_val: 2'b11,
    io_clk_val: 2'b11,
    main_pok: 1'b1
  };

endpackage

module ichild (
  input  logic clk_i,
  output logic o
);
  ip::pwr_ast_rsp_t r;
  assign r = ip::RSP_DEFAULT;
  assign o = r.main_pok ^ clk_i;
endmodule

module ii (input logic clk_i, output logic o);
  ichild u_i (.clk_i(clk_i), .o(o));
endmodule
