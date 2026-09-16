// v11u53 BREAK-11: THE REALISTIC SHAPE.  The corpus witness
// (bits_of_type_param / CVA6's hpdcache) names its type parameter EXACTLY as
// the package typedef it defaults to.  Add the `import pk::*` that real
// designs write beside it and the parameter's own name is in the imported
// data-type map — Surelog folds, and the law must not refuse.
package pk;
  typedef struct packed {
    logic [31:0] addr;
    logic [63:0] data;
    logic        we;
  } req_t;                       // 97
endpackage
module dut import pk::*; #(
    parameter  type      req_t      = pk::req_t,
    parameter  int       DATA_WIDTH = $bits(req_t),
    localparam int       DIRECT     = $bits(pk::req_t)
) (
    input  logic  clk_i,
    input  logic [DATA_WIDTH-1:0] d_i,
    input  logic [DIRECT-1:0]     c_i,
    output logic  o
);
  assign o = ^{d_i, c_i};
endmodule
