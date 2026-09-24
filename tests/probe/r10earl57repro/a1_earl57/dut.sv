// r10earl57 a1 — THE CORPUS SHAPE, reduced.  prim_fifo_sync's
//   localparam int unsigned DepthW = (DepthWNorm == 0) ? 1 : DepthWNorm
// used as a SIZE CAST `DepthW'(Depth)` inside an IF-GENERATE cont-assign, in a
// CHILD instance so both the DEF and the ELAB listings exist.
//
// Golden (Surelog CompileType.cpp case slStringConst, step 3): the ELAB view
// resolves the cast-target NAME through the INSTANCE's netlist param_assigns
// and mints an int_typespec NAMED after the parameter, VALUED with the
// instance's folded value, at the param_assign's own line:col ZERO-WIDTH.
module fifo57 #(
  parameter  int unsigned Width      = 16,
  parameter  int unsigned Depth      = 4,
  localparam int unsigned DepthWNorm = $clog2(Depth+1),
  localparam int unsigned DepthW     = (DepthWNorm == 0) ? 1 : DepthWNorm
) (
  input                    clk_i,
  input  [Width-1:0]       wdata,
  output [DepthW-1:0]      depth
);
  if (Depth == 1) begin : gen_passthru_fifo
    assign depth = '0;
  end else begin : gen_normal_fifo
    logic full;
    logic [DepthW-1:0] wptr_value;
    assign full = 1'b0;
    assign wptr_value = '0;
    assign depth = (full) ? DepthW'(Depth) :
                   DepthW'(wptr_value) - DepthW'(Depth);
  end
endmodule

module top57 (input c, input [15:0] d, output [1:0] o);
  fifo57 #(.Width(16), .Depth(2)) i_f (.clk_i(c), .wdata(d), .depth(o));
endmodule
