// r10earl106 g2_form106 — THE CAST-WIDTH FORM axis in a gen-IF scope with a
// BOUND module-body Lhs.  Which typespec Surelog gives the cast decides the
// PRE-adjust encoding; adjustSize then re-decides size/decompile.
// MEASUREMENT ONLY.
package pg2_106;
  parameter int unsigned WU8 = 8;
  parameter int          WS8 = 8;
  parameter              WB8 = 8;      // untyped
  parameter int unsigned WU4 = 4;
  parameter int unsigned WU64 = 64;
  parameter int unsigned WU96 = 96;
endpackage

module g2_form106 #(parameter int unsigned MP8 = 8) (output logic [7:0] o);
  localparam int unsigned LP8 = 8;
  logic [7:0]  t8;
  logic [7:0]  t8b, t8c, t8d, t8e, t8f, t8g, t8h, t8i, t8j, t8k, t8l;
  logic [3:0]  t4a, t4b;
  logic [63:0] t64a, t64b;
  logic [95:0] t96a;
  logic [7:0]  tw1, tw2, tw3;

  // width written as a LITERAL
  if (1) begin : c_lit8    assign t8   = 8'(6'h3F);            end
  // width from a PACKAGE param, int unsigned / int / untyped
  if (1) begin : c_pu8     assign t8b  = pg2_106::WU8'(6'h3F); end
  if (1) begin : c_ps8     assign t8c  = pg2_106::WS8'(6'h3F); end
  if (1) begin : c_pb8     assign t8d  = pg2_106::WB8'(6'h3F); end
  // width from a LOCALPARAM / MODULE param
  if (1) begin : c_lp8     assign t8e  = LP8'(6'h3F);          end
  if (1) begin : c_mp8     assign t8f  = MP8'(6'h3F);          end
  // width from an EXPRESSION
  if (1) begin : c_clog    assign t8g  = ($clog2(256))'(6'h3F);end
  // TYPE casts
  if (1) begin : c_int     assign t8h  = int'(6'h3F);          end
  if (1) begin : c_byte    assign t8i  = byte'(6'h3F);         end
  if (1) begin : c_logic   assign t8j  = logic'(6'h3F);        end
  // NARROWER cast than the operand: does the cast mask before the adjust?
  if (1) begin : c_lit4    assign t8k  = 4'(6'h3F);            end
  if (1) begin : c_pu4     assign t8l  = pg2_106::WU4'(6'h3F); end
  // narrow Lhs
  if (1) begin : c_n4lit   assign t4a  = 8'(6'h3F);            end
  if (1) begin : c_n4pu    assign t4b  = pg2_106::WU8'(6'h3F); end
  // 64-bit Lhs (the sentinel collision)
  if (1) begin : c_w64lit  assign t64a = 8'(6'h3F);            end
  if (1) begin : c_w64big  assign t64b = 64'(64'hFFFF_FFFF_FFFF_FFFF); end
  // wider-than-word Lhs and cast
  if (1) begin : c_w96     assign t96a = pg2_106::WU96'(64'hFFFF_FFFF_FFFF_FFFF); end
  // NEGATIVE / signed operands
  if (1) begin : c_neg     assign tw1  = 8'(-1);               end
  if (1) begin : c_negs    assign tw2  = 8'(signed'(-8'sd3));  end
  // an operand that is a PARAMETER read (earl105's window neighbour)
  if (1) begin : c_pref    assign tw3  = 8'(pg2_106::WU8);     end
  assign o = t8;
endmodule
