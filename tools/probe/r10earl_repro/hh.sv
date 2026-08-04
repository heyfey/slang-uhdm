// r10earl4 hh.sv — § impCopyBasedDecKeep, the DISTINGUISHER.
// gg.sv's gchild (no parameter port list) already keeps the package's `2'd1`
// in its DEF listing.  ibex_alu HAS one (`#(parameter bit RV32B = 1'b0)`) and
// § modDefImportShape therefore flips its DEF listing to the ELAB shape --
// which re-spells the DEC-based literal to INT.  Golden keeps `2'd1` DEC in
// EVERY module DEF listing (12 Earlgrey heads: ibex_alu, ibex_controller,
// ibex_core, ibex_cs_registers, ibex_decoder, ibex_ex_block, ibex_id_stage,
// ibex_if_stage, ibex_multdiv_fast, ibex_pmp, ibex_wb_stage, ...) and folds
// to INT only in the ELABORATED instances.
// hchild = ibex_alu's shape (param port list), kchild = gg's control.
package hp;
  parameter logic [1:0] HDEC  = 2'd1;
  parameter logic [3:0] HHEX  = 4'h2;
  parameter logic [3:0] HOCT  = 4'o7;
  parameter logic [3:0] HBIN  = 4'b1010;
endpackage

module hchild #(
  parameter bit RV = 1'b0
) (
  input  logic [3:0] i,
  output logic [3:0] o
);
  import hp::*;
  assign o = i ^ {2'b0, HDEC} ^ HHEX ^ HOCT ^ HBIN ^ {3'b0, RV};
endmodule

module kchild (
  input  logic [3:0] i,
  output logic [3:0] o
);
  import hp::*;
  assign o = i ^ {2'b0, HDEC} ^ HHEX ^ HOCT ^ HBIN;
endmodule

module hh (input logic [3:0] i, output logic [3:0] o, output logic [3:0] o2);
  hchild u_h (.i(i), .o(o));
  kchild u_k (.i(i), .o(o2));
endmodule
