// r11u75 g4 — THE EDGES OF ALL THREE LAWS, measured rather than guessed.
//  * a COMPILATION-UNIT wildcard import (the module names no package at all):
//    Surelog materialises the package listing TWICE for a $unit import, so the
//    holder exists — does the gen-scope cell bind it?
//  * a STRUCT net and an UNPACKED-ARRAY net namesake one scope out (LAW A's
//    other two net stores).
//  * a gen-scope localparam base read from a gen-if arm and from a gen-case
//    arm (LAW C's generate KIND question, which pass 73 answered NO for the
//    module-level base).
package pun;
  logic [15:0] un_ns;
endpackage
package ps;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } sp_t;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.n = x;
    c.t = 8'h5A;
    return c;
  endfunction
endpackage

import pun::*;                      // COMPILATION-UNIT wildcard import

module dut (output logic [31:0] o);
  for (genvar i = 0; i < 1; i = i + 1) begin : E1
    ps::sp_t sn_ns;                 // a STRUCT net one scope out
    wire [7:0] an_ns [0:1];         // an UNPACKED-ARRAY net one scope out
    assign sn_ns = 16'd9;
    assign an_ns[0] = 8'd9;
    if (1) begin : E2
      logic [31:0] un_ns;  assign un_ns  = 32'd1;  // $unit-imported namesake
      logic [15:0] sn_ns;  assign sn_ns  = 16'd2;  // struct-net namesake
      logic [7:0]  an_ns;  assign an_ns  = 8'd3;   // array-net namesake
    end
  end
  if (1) begin : F1
    localparam ps::cfg_t F_LOC = ps::build(96);
    logic [31:0] f_if;
    assign f_if = F_LOC.n;          // gen-IF arm, gen-scope base
  end
  case (1)
    1: begin : F2
      localparam ps::cfg_t C_LOC = ps::build(112);
      logic [31:0] f_case;
      assign f_case = C_LOC.n;      // gen-CASE arm, gen-scope base
    end
  endcase
  assign o = E1[0].E2.un_ns ^ E1[0].E2.sn_ns ^ E1[0].E2.an_ns
           ^ F1.f_if ^ F2.f_case;
endmodule
