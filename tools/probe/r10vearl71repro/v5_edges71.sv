// r10v71 arm v5 — MEASUREMENT ONLY.  Edge shapes no arm covers: nested
// part-selects, call args, modport/interface connections, output-direction
// high_conns, gen-if else, escaped and macro-written qualifiers, x/z and
// non-integer package parameters.
`define QP pq_v71::QP
package pq_v71;
  parameter  int EP = 16;
  parameter  int QP = 16;
  parameter  int XP = 32'bx;          // UNKNOWN value
  parameter  real RP = 3.5;           // non-integer
  parameter  int SEL = 2;
  parameter  logic [63:0] VECP = 64'h0000_0000_0000_0020;
endpackage

interface iv71 (input logic clk);
  logic [63:0] d;
  modport mp (input d);
endinterface

module lev71 (
  input  [63:0] c0, input  [63:0] c1, input  [63:0] c2, input  [63:0] c3,
  input  [63:0] c4, input  [63:0] c5, input  [63:0] c6, output [63:0] c7,
  input  [63:0] c8);
endmodule

module lmp71 (iv71.mp mif, input [63:0] c0);
endmodule

function automatic [63:0] idf71(input [63:0] v); idf71 = v; endfunction

module m5_v71 import pq_v71::*; (input logic clk, input [63:0] sig,
                                 output logic [63:0] o0, output logic [63:0] ow);
  logic [63:0] idx;
  iv71 u_if (.clk(clk));

  for (genvar g = 0; g < 2; g++) begin: ge
    lev71 i0 (
      .c0(sig[VECP[EP:0]:0]),         // nested: bound is itself a part-select
      .c1(idf71(sig[63:EP])),         // the bound inside a CALL ARG
      .c2(sig[63:`QP]),               // MACRO-written pkg::P
      .c3(sig[63:pq_v71::EP]),        // written pkg::P
      .c4(sig[63:XP]),                // x-valued package parameter
      .c5(sig[EP +: 8]),              // indexed part select base
      .c6({sig[63:EP], sig[EP:0]}),
      .c7(ow[63:EP]),                 // OUTPUT direction high_conn
      .c8(sig[63:EP])
    );
    lmp71 i1 (.mif(u_if.mp), .c0(sig[63:EP]));
  end

  if (SEL == 9) begin: gthen
    lev71 i0 (.c0(sig[63:EP]), .c1(sig[63:EP]), .c2(sig[63:EP]), .c3(sig[63:EP]),
              .c4(sig[63:EP]), .c5(sig[63:EP]), .c6(sig[63:EP]), .c7(ow[63:EP]),
              .c8(sig[63:EP]));
  end else begin: gelse
    lev71 i0 (.c0(sig[63:EP]), .c1(sig[63:EP]), .c2(sig[63:EP]), .c3(sig[63:EP]),
              .c4(sig[63:EP]), .c5(sig[63:EP]), .c6(sig[63:EP]), .c7(ow[63:EP]),
              .c8(sig[63:EP]));
  end

  case (SEL)
    2: begin: gcase
      lev71 i0 (.c0(sig[63:EP]), .c1(sig[63:EP]), .c2(sig[63:EP]), .c3(sig[63:EP]),
                .c4(sig[63:EP]), .c5(sig[63:EP]), .c6(sig[63:EP]), .c7(ow[63:EP]),
                .c8(sig[63:EP]));
    end
  endcase
  assign idx = sig;
  assign o0 = sig ^ {32'd0, $rtoi(RP)};
endmodule
