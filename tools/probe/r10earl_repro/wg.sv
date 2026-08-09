// wg.sv — PASS 15: the § pkgTypespecInstanceIsTop signature, isolated.
// The dm_mem / rv_dm heads read
//     failLhs constant dm_pkg.sv:29:43 {ct=9 sz=64 dec=2052}
//        ^ param_assign ^ package 'dm' {top=1 uid=16}    ^ design
//     failRhs operation :29:43
//        ^ param_assign ^ package 'dm' {top=0 uid=5892}  ^ design
// i.e. NOT a fold bug at all: uhdm-cmp recursed a typespec's Instance() and
// golden landed in the ELABORATED package (where `H + 4` is folded) while we
// landed in the DEFINITION package (where it is still an operation).  dm_mem
// has NO import — every reference is qualified `dm::` — so the back-edge must
// come from a package TYPEDEF used as a variable/port type, or from a
// qualified parameter read.  This witness carries one of each, and its package
// has an OPERATION-init localparam so the def and elaborated copies of the
// package differ observably.
package wgp;
  localparam logic [63:0] H = 64'h800;
  localparam logic [63:0] R = H + 4;   // op in allPackages, constant in topPackages
  localparam int DC = 2;
  typedef struct packed {
    logic [7:0] a;
    logic [7:0] b;
  } cmd_t;
  typedef enum logic [1:0] { EA = 2'd0, EB = 2'd1 } err_e;
  function automatic logic [31:0] jal(logic [4:0] rd);
    return {27'b0, rd};
  endfunction
endpackage

module wgnp #(
  parameter int unsigned NrHarts = 1
) (
  input  logic                       clk_i,
  input  wgp::cmd_t                  cmd_i,     // package STRUCT as a port type
  output wgp::err_e                  err_o,     // package ENUM as a port type
  input  logic [wgp::DC-1:0][31:0]   data_i,    // qualified param in a bound
  output logic [31:0]                rdata_o
);
  wgp::cmd_t ac;                                 // package struct as a var type
  assign ac = cmd_i;
  assign err_o = wgp::EA;                        // package enum constant
  assign rdata_o = wgp::jal(5'd10) ^ 32'(wgp::R[11:0]);  // pkg func + qual param
endmodule

module wgtop;
  logic c;
  wgp::cmd_t cm;
  wgp::err_e er;
  logic [1:0][31:0] d;
  logic [31:0] r;
  wgnp u0(.clk_i(c), .cmd_i(cm), .err_o(er), .data_i(d), .rdata_o(r));
endmodule
