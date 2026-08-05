// r10earl10 witness: the PTRV_W class (5 Earlgrey heads, untouched for six
// passes).  prim_fifo_async.sv:33-35
//     localparam int unsigned PTRV_W = $clog2(Depth);
//     localparam logic [PTRV_W-1:0] DepthMinus1 = PTRV_W'(Depth - 1);
// r10earl10p over the two designs isolates it to ONE field: the def listing's
// PTRV_W int_typespec carries a Cast_to_expr ref_obj whose Actual_group is
// BOUND to the parameter in golden and NULL in ours.  Everything else in both
// Parameters() and Param_assigns() is identical.  DepthW (a PORT-LIST
// localparam with the same `$clog2` shape) IS bound on both sides, so the
// distinguisher is where the localparam is DECLARED, not the cast.
module ve_sub #(
  parameter  int unsigned Width  = 16,
  parameter  int unsigned Depth  = 3,
  localparam int unsigned DepthW = $clog2(Depth+1)
) (
  input  logic              clk_i,
  output logic [DepthW-1:0] o
);
  localparam int unsigned PTRV_W = $clog2(Depth);
  localparam logic [PTRV_W-1:0] DepthMinus1 = PTRV_W'(Depth - 1);
  localparam int unsigned PTR_WIDTH = PTRV_W+1;

  logic [PTR_WIDTH-1:0] ptr;
  assign ptr = '0;
  assign o = DepthW'(DepthMinus1) ^ {{(DepthW-1){1'b0}}, ptr[0]};
endmodule

module ve (input logic clk_i, output logic [1:0] o);
  ve_sub #(.Width(8), .Depth(3)) u_a (.clk_i(clk_i), .o(o));
endmodule
