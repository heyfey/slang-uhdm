// r10earl6 ss.sv — the prim_lfsr class (2 Earlgrey heads: prim_lfsr,
// ibex_dummy_instr):
//     failLhs int_typespec 'LfsrDw'  prim_lfsr.sv:33:32
//     failRhs logic_typespec ''      :39:47
// prim_lfsr.sv:33 is `parameter int unsigned LfsrDw = 32` and :39 is
//     parameter logic [LfsrDw-1:0] DefaultSeed = LfsrDw'(1),
// so a SIZE CAST written with a PARAMETER NAME (`LfsrDw'(1)`) takes that
// parameter's OWN typespec — an int_typespec carrying the parameter's NAME,
// at the parameter's declaration — where we mint a fresh anonymous
// logic_typespec at the cast site.
module schild #(
  // row A — the prim_lfsr shape
  parameter int unsigned    SDw  = 32,
  parameter logic [SDw-1:0] Seed = SDw'(1),
  // row B — a LITERAL-sized cast (control)
  parameter logic [7:0]     Lit  = 8'(1),
  // row C — a cast named by a plain (untyped) parameter
  parameter                 SN   = 4,
  parameter logic [7:0]     CN   = SN'(3),
  // row D — a cast named by a `localparam`-like signed int parameter
  parameter int             SI   = 6,
  parameter logic [7:0]     CI   = SI'(2)
) (
  input  logic             clk_i,
  output logic [SDw-1:0]   o
);
  assign o = Seed ^ {{(SDw-8){1'b0}}, Lit} ^ {{(SDw-8){1'b0}}, CN}
             ^ {{(SDw-8){1'b0}}, CI} ^ {SDw{clk_i}};
endmodule

module ss (input logic clk_i, output logic [31:0] o);
  schild u_s (.clk_i(clk_i), .o(o));
endmodule
