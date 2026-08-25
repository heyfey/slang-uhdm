// r10earl90 g2 — THE DECLARED-TYPE GRID AT THE **WIDTH** SLOT.
// Every row is the SAME read — an ELABORATED port high_conn inside a gen-for,
// `sig[g*2 +: P]` with P == 2 — and differs only in P's DECLARED TYPE.  It is
// the WIDTH-slot twin of r10earl84's g2_types84.sv (which measured the BASE),
// and it tests `CompileHelper::valueRange`'s three-kind switch: a SIGNED
// `int` / `bit` / `logic` declared type (a typedef of one included) makes
// `sval->isSigned()` TRUE and CompileExpression.cpp:3004-3018 stamps the bare
// signed `int_typespec`; every other kind leaves it FALSE.
package pk90;
  localparam int                PKG_I  = 2;
  localparam int unsigned       PKG_IU = 2;
  localparam logic signed [7:0] PKG_LS = 8'sd2;
  localparam logic [7:0]        PKG_LU = 8'd2;
endpackage

module snk2_90 (input logic [1:0] a_i);
endmodule

module g2_types90;
  import pk90::*;
  typedef logic [7:0]        byte_t90;
  typedef logic signed [7:0] ls_t90;

  localparam int                p_int    = 2;
  localparam int signed         p_isg    = 2;
  localparam int unsigned       p_iun    = 2;
  localparam integer            p_intg   = 2;
  localparam byte               p_byte   = 2;
  localparam shortint           p_shrt   = 2;
  localparam longint            p_long   = 2;
  localparam bit [3:0]          p_bit    = 4'd2;
  localparam bit signed [3:0]   p_bsg    = 4'sd2;
  localparam logic [7:0]        p_lgc    = 8'd2;
  localparam logic signed [7:0] p_lsg    = 8'sd2;
  localparam byte_t90           p_tdu    = 8'd2;
  localparam ls_t90             p_tds    = 8'sd2;
  localparam signed [7:0]       p_impsg  = 8'sd2;   // IMPLICIT type, signed
  localparam [7:0]              p_impun  = 8'd2;    // IMPLICIT type, unsigned
  localparam                    p_untyp  = 2;       // UNTYPED

  logic [31:0] sig;

  for (genvar g = 0; g < 1; g++) begin : gt
    snk2_90 u01 (.a_i(sig[g*2 +: p_int  ]));
    snk2_90 u02 (.a_i(sig[g*2 +: p_isg  ]));
    snk2_90 u03 (.a_i(sig[g*2 +: p_iun  ]));
    snk2_90 u04 (.a_i(sig[g*2 +: p_intg ]));
    snk2_90 u05 (.a_i(sig[g*2 +: p_byte ]));
    snk2_90 u06 (.a_i(sig[g*2 +: p_shrt ]));
    snk2_90 u07 (.a_i(sig[g*2 +: p_long ]));
    snk2_90 u08 (.a_i(sig[g*2 +: p_bit  ]));
    snk2_90 u09 (.a_i(sig[g*2 +: p_bsg  ]));
    snk2_90 u10 (.a_i(sig[g*2 +: p_lgc  ]));
    snk2_90 u11 (.a_i(sig[g*2 +: p_lsg  ]));
    snk2_90 u12 (.a_i(sig[g*2 +: p_tdu  ]));
    snk2_90 u13 (.a_i(sig[g*2 +: p_tds  ]));
    snk2_90 u14 (.a_i(sig[g*2 +: p_impsg]));
    snk2_90 u15 (.a_i(sig[g*2 +: p_impun]));
    snk2_90 u16 (.a_i(sig[g*2 +: p_untyp]));
    snk2_90 u17 (.a_i(sig[g*2 +: PKG_I  ]));   // PACKAGE parameter (fence c)
    snk2_90 u18 (.a_i(sig[g*2 +: pk90::PKG_I])); // qualified package read
    snk2_90 u19 (.a_i(sig[g*2 +: pk90::PKG_IU])); // qualified, int unsigned
    snk2_90 u20 (.a_i(sig[g*2 +: pk90::PKG_LS])); // qualified, logic signed
    snk2_90 u21 (.a_i(sig[g*2 +: pk90::PKG_LU])); // qualified, logic unsigned
  end
endmodule
