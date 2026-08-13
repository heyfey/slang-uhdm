// r10uvm67 arm a1 — WHICH PACKAGE PARAMETERS GET A TYPESPEC ON THEIR OWN
// param_assign Rhs CONSTANT, and what is that typespec's SPAN and its
// ref_typespec NAME?
//
// The witness (measured on uvm-1.2 src/base/uvm_globals.svh:410, read from the
// cmp head, not guessed):
//
//   407  parameter UVM_LINE_WIDTH = `UVM_LINE_WIDTH;      // 120
//   408  parameter UVM_NUM_LINES  = `UVM_NUM_LINES;       // 120
//   409  parameter UVM_SMALL_STRING = UVM_LINE_WIDTH*8-1;             //    959
//   410  parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;  // 115199
//
// golden head: constant @410:30-410:60 under param_assign @410:11-410:62,
// vpiSize 32, INT:115199, vpiConstType 7, vpiDecompile 115199,
// vpiTypespec -> ref_typespec (fullname `uvm_pkg`) -> int_typespec @410:1-410:62.
//
// EVERY cell below is a package-scope parameter.  The axes, one per group:
//   A  written INITIALIZER form   (literal / macro-literal / folded expression)
//   B  explicit TYPE vs implicit  (`parameter int P` vs `parameter P`)
//   C  parameter vs localparam
//   D  the SPAN the int_typespec takes (whole declaration vs the type token)
//   E  the ref_typespec NAME (is it the PACKAGE, the parameter, or the type?)
// The module-scope twin lives in a2; the multi-declaration/`,`-list and the
// macro/`include span questions live in a3.

`define A1_LINE_WIDTH 120
`define A1_NUM_LINES 120

package a1pkg;

  // --- group A: the witness chain, verbatim in shape ----------------------
  parameter A1_LINE_WIDTH = `A1_LINE_WIDTH;
  parameter A1_NUM_LINES = `A1_NUM_LINES;
  parameter A1_SMALL_STRING = A1_LINE_WIDTH*8-1;
  parameter A1_LARGE_STRING = A1_LINE_WIDTH*A1_NUM_LINES*8-1;

  // --- group B: the same VALUES, other initializer forms -------------------
  parameter A1_LIT = 115199;                 // b01 plain decimal literal
  parameter A1_LIT_SIZED = 32'd115199;       // b02 sized decimal literal
  parameter A1_LIT_HEX = 32'h1C1FF;          // b03 sized hex literal
  parameter A1_ARITH_LIT = 120*120*8-1;      // b04 folded over LITERALS only
  parameter A1_ONEPARAM = A1_LINE_WIDTH;     // b05 a bare parameter reference
  parameter A1_ONEPARAM_ADD = A1_LINE_WIDTH+1;  // b06 one param, one operator
  parameter A1_PARENS = (A1_LINE_WIDTH*8)-1; // b07 written parentheses
  parameter A1_NEG = -A1_LINE_WIDTH;         // b08 unary, negative value

  // --- group C: EXPLICIT TYPES, same initializer forms ----------------------
  parameter int A1_T_FOLD = A1_LINE_WIDTH*8-1;   // c01 typed  + folded
  parameter int A1_T_LIT = 959;                  // c02 typed  + literal
  parameter integer A1_TI_FOLD = A1_LINE_WIDTH*8-1;   // c03 integer + folded
  parameter bit [31:0] A1_TB_FOLD = A1_LINE_WIDTH*8-1;  // c04 packed + folded
  parameter logic [31:0] A1_TL_FOLD = A1_LINE_WIDTH*8-1;  // c05 logic + folded
  parameter byte A1_TBY_FOLD = 8'd7 + 1;         // c06 byte + folded
  parameter shortint A1_TS_FOLD = A1_LINE_WIDTH + 1;  // c07 shortint + folded
  parameter int unsigned A1_TU_FOLD = A1_LINE_WIDTH*8-1;  // c08 unsigned int
  parameter string A1_TSTR = "abc";              // c09 string (control)

  // --- group D: localparam twins -------------------------------------------
  localparam A1_L_FOLD = A1_LINE_WIDTH*8-1;      // d01 localparam + folded
  localparam A1_L_LIT = 959;                     // d02 localparam + literal
  localparam int A1_LT_FOLD = A1_LINE_WIDTH*8-1; // d03 localparam typed folded

  // --- group E: span probes -------------------------------------------------
  // e01 the declaration runs over TWO source lines
  parameter A1_TWOLINE =
      A1_LINE_WIDTH*8-1;
  // e02 a comma-separated LIST in ONE declaration (two param_assigns, one decl)
  parameter A1_LIST_A = A1_LINE_WIDTH*2, A1_LIST_B = A1_LINE_WIDTH*3;
  // e03 leading whitespace before `parameter` (does the ts span start at col 1
  //     of the line, or at the `parameter` keyword?)
      parameter A1_INDENTED = A1_LINE_WIDTH*4;
  // e04 a trailing comment after the semicolon
  parameter A1_TRAILCOM = A1_LINE_WIDTH*5;  // trailing comment
  // e05 the whole declaration comes from a MACRO
  `define A1_WHOLEDECL parameter A1_MACRO_DECL = 120*7;
  `A1_WHOLEDECL

  // --- group F: value-encoding probes ---------------------------------------
  parameter A1_BIG = A1_LINE_WIDTH*A1_NUM_LINES*A1_NUM_LINES*8;  // f01 > 2^20
  parameter A1_ZERO = A1_LINE_WIDTH - `A1_LINE_WIDTH;            // f02 zero
  parameter A1_DIV = A1_LINE_WIDTH/8;                            // f03 divide
  parameter A1_SHIFT = A1_LINE_WIDTH << 2;                       // f04 shift
  parameter A1_CAT = {A1_LINE_WIDTH[3:0], 4'h1};                 // f05 concat
  parameter A1_TERN = (A1_LINE_WIDTH > 8) ? 1 : 2;               // f06 ternary

endpackage : a1pkg

module a1top;
  import a1pkg::*;
  initial $display("%0d %0d %0d", A1_LARGE_STRING, A1_SMALL_STRING, A1_T_FOLD);
endmodule
