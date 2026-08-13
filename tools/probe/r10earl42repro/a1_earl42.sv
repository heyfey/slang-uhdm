// r10earl42 GRID — concat / assignment-pattern OPERAND ORDER and the
// vpiReordered flag, per POSITION (package param / module param / module var /
// port connection) and per SHAPE (concat vs pattern, constant- vs ref-headed,
// 1 packed dim vs 2, descending vs ascending outer range, nested).
//
// THE TARGET CELL is b1: Earlgrey tl_main_pkg.sv:13
//     localparam logic [3:0][31:0] ADDR_SPACE_PERI = { 32'h..., x4 };
// LHS(golden) = source order, NO vpiReordered.   RHS(ours) = reversed + flag.
//
// LHS is ALWAYS golden (Surelog).  Cell ids are in the comments so the grid
// script can key on the parameter NAME.

package q42;

  // ---- b1: THE TARGET SHAPE — pkg, 2 packed dims, descending outer,
  //      CONCAT, CONSTANT-headed operands.
  localparam logic [3:0][31:0] B1_PKG_CC = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- b2: same but ASSIGNMENT PATTERN '{...}
  localparam logic [3:0][31:0] B2_PKG_PC = '{
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- b3: ASCENDING outer packed range, concat, constants
  localparam logic [0:3][31:0] B3_PKG_ASC = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- b4: ONE packed dim (flat vector), concat of constants
  localparam logic [31:0] B4_PKG_FLAT = {8'h11, 8'h22, 8'h33, 8'h44};

  // ---- b5: REF-headed concat, 2 packed dims, descending — the shape the
  //      existing § applyPkgParamPatternReorder law was measured on.
  localparam logic [31:0] R0 = 32'h 40000000;
  localparam logic [31:0] R1 = 32'h 40080000;
  localparam logic [31:0] R2 = 32'h 400a0000;
  localparam logic [31:0] R3 = 32'h 40150000;
  localparam logic [3:0][31:0] B5_PKG_CR = {R0, R1, R2, R3};

  // ---- b6: NESTED concat, 3 packed dims, all descending
  localparam logic [1:0][1:0][31:0] B6_PKG_NEST = {
    {32'h 40000000, 32'h 40080000},
    {32'h 400a0000, 32'h 40150000}
  };

  // ---- b7: UNPACKED array of int, pattern (unpacked needs '{ })
  localparam int B7_PKG_UP [4] = '{32'h 40000000, 32'h 40080000,
                                   32'h 400a0000, 32'h 40150000};

  // ---- b8: UNPACKED array, DESCENDING written range
  localparam int B8_PKG_UPD [3:0] = '{32'h 40000000, 32'h 40080000,
                                      32'h 400a0000, 32'h 40150000};

  // ---- b9: struct-free 2-dim concat with SYMBOLIC outer bound
  localparam int NW = 4;
  localparam logic [NW-1:0][31:0] B9_PKG_SYM = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

endpackage

module m42 (input logic clk, output logic [31:0] o);

  // ---- c1: MODULE param, target shape (concat, constants, 2 dims, desc)
  localparam logic [3:0][31:0] C1_MOD_CC = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- c2: MODULE param, assignment pattern
  localparam logic [3:0][31:0] C2_MOD_PC = '{
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- c3: MODULE VAR with the same initializer (not a param at all)
  logic [3:0][31:0] C3_MOD_VAR = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- c4: continuous assignment rhs concat
  logic [3:0][31:0] c4_net;
  assign c4_net = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- c5: procedural assignment rhs concat
  logic [3:0][31:0] c5_reg;
  always_comb c5_reg = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };

  // ---- c6: PORT CONNECTION concat (param port of a child)
  sub42 #(.P({32'h 40000000, 32'h 40080000, 32'h 400a0000, 32'h 40150000}))
    u_sub (.clk(clk), .o(o));

  // ---- c7: reference to the package target, to force elaboration
  localparam logic [31:0] C7_USE = q42::B1_PKG_CC[0];

endmodule

module sub42 #(parameter logic [3:0][31:0] P = '0)
              (input logic clk, output logic [31:0] o);
  assign o = P[0] ^ {32{clk}};
endmodule

// THE EARLGREY SHAPE VERBATIM: a WILDCARD IMPORT inside a module body, which
// MATERIALIZES the package localparam as a param_assign in BOTH module
// listings (top_earlgrey.sv:62 / xbar_main.sv:122 do exactly this).
module mimp42 (input logic clk, output logic [31:0] o);
  import q42::*;
  assign o = B1_PKG_CC[0] ^ B5_PKG_CR[0] ^ B6_PKG_NEST[0][0] ^ {32{clk}};
endmodule

// A MODULE'S OWN DECLARED PARAMETER whose default is a 3-dim concat of nested
// concats — the § multiDimPatternReorderRec witness shape (BlackParrotComplex
// `bit [1:0][4:0][4:0] StrictXY` reached through `routing_matrix_p`).
module mown42 #(parameter bit [1:0][4:0][4:0] D1_OWN_NEST =
                  {{5'b01111, 5'b10111, 5'b00011, 5'b00101, 5'b11111},
                   {5'b01001, 5'b10001, 5'b11011, 5'b11101, 5'b11111}})
               (input logic clk, output logic [4:0] o);
  assign o = D1_OWN_NEST[0][0] ^ {5{clk}};
endmodule

module mown42b #(parameter logic [3:0][31:0] D2_OWN_FLAT =
                   {32'h 40000000, 32'h 40080000, 32'h 400a0000, 32'h 40150000})
                (input logic clk, output logic [31:0] o);
  assign o = D2_OWN_FLAT[0] ^ {32{clk}};
endmodule

module top42 (input logic clk, output logic [31:0] o1, output logic [31:0] o2,
              output logic [4:0] o3, output logic [31:0] o4);
  m42     u_m   (.clk(clk), .o(o1));
  mimp42  u_imp (.clk(clk), .o(o2));
  mown42  u_own (.clk(clk), .o(o3));
  mown42b u_ownb(.clk(clk), .o(o4));
endmodule
