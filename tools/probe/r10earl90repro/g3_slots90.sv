// r10earl90 g3 — THE SLOT / OPERAND-SHAPE GRID at the ELABORATED gen-scope
// port high_conn (the site § connIpsWidthNonOvParamSignedTs90 owns).
// SLOTS: indexed_part_select BASE and WIDTH, bit_select INDEX, part_select
// LEFT and RIGHT, a var_select index.  OPERAND SHAPES: a bare signed-int
// localparam, a bare UNSIGNED-int localparam, an EXPRESSION, a literal, a
// genvar, and a package parameter.  Only the shapes golden's identifier arm
// answers may move.
module snk4_90 (input logic [3:0] a_i);
endmodule
module snk1_90 (input logic a_i);
endmodule
module snk2b90 (input logic [1:0] a_i);
endmodule

module g3_slots90;
  localparam int          P4  = 4;   // signed int   -> golden stamps
  localparam int          P2  = 2;
  localparam int unsigned Q2  = 2;   // int unsigned -> golden stamps NOTHING
  logic [31:0] sig;
  logic [3:0]  mem [0:7];

  for (genvar g = 0; g < 1; g++) begin : gs
    // ---- indexed_part_select, WIDTH slot -------------------------------
    snk4_90 w01 (.a_i(sig[g*4 +: P4    ]));   // bare signed-int localparam
    snk2b90 w02 (.a_i(sig[g*4 +: Q2    ]));   // bare int-unsigned localparam
    snk4_90 w03 (.a_i(sig[g*4 +: P2*2  ]));   // EXPRESSION width
    snk4_90 w04 (.a_i(sig[g*4 +: 4     ]));   // LITERAL width
    snk4_90 w05 (.a_i(sig[g*4 +: g+4   ]));   // GENVAR-bearing width
    // ---- indexed_part_select, BASE slot --------------------------------
    snk4_90 b01 (.a_i(sig[P4   +: 4    ]));   // bare signed-int localparam base
    snk4_90 b02 (.a_i(sig[Q2   +: 4    ]));   // bare int-unsigned base
    snk4_90 b03 (.a_i(sig[P2*2 +: 4    ]));   // EXPRESSION base
    snk4_90 b04 (.a_i(sig[4    +: 4    ]));   // LITERAL base
    snk4_90 b05 (.a_i(sig[g    +: 4    ]));   // GENVAR base
    snk4_90 b06 (.a_i(sig[P4   +: P4   ]));   // BOTH slots a bare localparam
    // ---- bit_select INDEX ---------------------------------------------
    snk1_90 i01 (.a_i(sig[P4          ]));    // bare signed-int localparam idx
    snk1_90 i02 (.a_i(sig[Q2          ]));
    snk1_90 i03 (.a_i(sig[P2*2        ]));
    snk1_90 i04 (.a_i(sig[4           ]));
    snk1_90 i05 (.a_i(sig[g           ]));
    // ---- part_select LEFT / RIGHT --------------------------------------
    snk4_90 p01 (.a_i(sig[P4+3 : P4   ]));    // RIGHT is a bare localparam
    snk4_90 p02 (.a_i(sig[7    : P4   ]));
    snk4_90 p03 (.a_i(sig[P4   : 1    ]));    // LEFT is a bare localparam
    snk4_90 p04 (.a_i(sig[7    : 4    ]));    // both literal
    // ---- var_select (unpacked element) ---------------------------------
    snk4_90 v01 (.a_i(mem[P4-1]));
    snk4_90 v02 (.a_i(mem[g]));
  end
endmodule
