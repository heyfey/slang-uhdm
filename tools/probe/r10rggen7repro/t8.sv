// r10rggen7 t8: does a PARAMETER reference inside an ELABORATED GEN-SCOPE
// process fold to that parameter's own elaborated constant?  The same read
// appears at module level (where the elab view SHARES the def-view process
// object and the ref survives) and inside a generate scope, for a module
// PARAMETER, a module LOCALPARAM and a GEN-SCOPE localparam.
// Rggen rggen_bit_field:259 `value <= INITIAL_VALUE;` inside
// `generate if (STORAGE) begin : g_value` (~670 gen-tree vectors): golden
// gives HEX:0 / 4'h0 / size 4, we keep the ref_obj.
module t8 #(
  parameter bit [3:0] IV = '0,
  parameter bit       EN = 1'b1
)(
  input  logic       clk,
  output logic [3:0] o_mod,
  output logic [3:0] o_gen,
  output logic [3:0] o_gen_lp,
  output logic [3:0] o_gen_gl
);
  localparam bit [3:0] LP = 4'h3;

  always_ff @(posedge clk) begin
    o_mod <= IV;
  end

  generate if (EN) begin : g_val
    localparam bit [3:0] GL = 4'h7;
    always_ff @(posedge clk) begin
      o_gen    <= IV;
      o_gen_lp <= LP;
      o_gen_gl <= GL;
    end
  end
  else begin : g_off
    always_ff @(posedge clk) begin
      o_gen <= LP;
    end
  end endgenerate
endmodule

module t8_top;
  logic clk;
  logic [3:0] a, b, c, d;
  t8 #(.IV(4'ha), .EN(1'b1)) u_t8 (.clk(clk), .o_mod(a), .o_gen(b),
                                   .o_gen_lp(c), .o_gen_gl(d));
endmodule
