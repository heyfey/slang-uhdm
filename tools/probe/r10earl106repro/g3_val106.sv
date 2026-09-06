// r10earl106 g3_val106 — THE VALUE-FORM axis (what the cast folds) and the
// NON-CAST ORIGINS this law must leave alone, all in a gen-IF scope with a
// BOUND module-body Lhs.  MEASUREMENT ONLY.
package pg3_106;
  parameter int unsigned W8 = 8;
  parameter int unsigned P63 = 63;
endpackage

module g3_val106 (output logic [7:0] o);
  localparam int unsigned LW = 8;
  logic [7:0] v_bin, v_hex, v_oct, v_dec, v_neg, v_xz, v_zz;
  logic [7:0] v_un, v_ub1, v_ub0;
  logic [7:0] v_par, v_cat, v_rep, v_bop, v_ter, v_sys, v_nest, v_catcast;
  logic [7:0] n_lit, n_par, n_cat, n_rep, n_bop, n_ter, n_sys, n_ub;
  logic [7:0] v_wide;
  logic [95:0] v_w96;

  // ---- CAST ORIGIN, value forms ----
  if (1) begin : v_binx   assign v_bin = 8'(6'b111111);        end
  if (1) begin : v_hexx   assign v_hex = 8'(6'h3F);            end
  if (1) begin : v_octx   assign v_oct = 8'(6'o77);            end
  if (1) begin : v_decx   assign v_dec = 8'(6'd63);            end
  if (1) begin : v_negx   assign v_neg = 8'(-3);               end
  if (1) begin : v_xzx    assign v_xz  = 8'(6'b1111xx);        end
  if (1) begin : v_zzx    assign v_zz  = 8'(6'bzzzzzz);        end
  if (1) begin : v_unx    assign v_un  = 8'(63);               end
  if (1) begin : v_ub1x   assign v_ub1 = 8'('1);               end
  if (1) begin : v_ub0x   assign v_ub0 = 8'('0);               end
  // cast of a PARAMETER read / a CONCAT / a REPLICATION / a BINARY op /
  // a TERNARY / a SYSTEM call / a NESTED cast
  if (1) begin : v_parx   assign v_par = 8'(pg3_106::P63);     end
  if (1) begin : v_catx   assign v_cat = 8'({2'b11,4'hF});     end
  if (1) begin : v_repx   assign v_rep = 8'({6{1'b1}});        end
  if (1) begin : v_bopx   assign v_bop = 8'(60 + 3);           end
  if (1) begin : v_terx   assign v_ter = 8'(LW==8 ? 63 : 1);   end
  if (1) begin : v_sysx   assign v_sys = 8'($clog2(64));       end
  if (1) begin : v_nestx  assign v_nest= 8'(4'(6'h3F));        end
  if (1) begin : v_ccx    assign v_catcast = 8'({4'h3,4'hF});  end
  if (1) begin : v_widex  assign v_wide = 96'(64'h3F);         end
  if (1) begin : v_w96x   assign v_w96 = 96'(64'hFFFF_FFFF_FFFF_FFFF); end

  // ---- NON-CAST ORIGINS (other laws own these; must not move) ----
  if (1) begin : n_litx   assign n_lit = 6'h3F;                end
  if (1) begin : n_parx   assign n_par = pg3_106::P63;         end
  if (1) begin : n_catx   assign n_cat = {2'b11,4'hF};         end
  if (1) begin : n_repx   assign n_rep = {6{1'b1}};            end
  if (1) begin : n_bopx   assign n_bop = 60 + 3;               end
  if (1) begin : n_terx   assign n_ter = (LW==8) ? 63 : 1;     end
  if (1) begin : n_sysx   assign n_sys = $clog2(64);           end
  if (1) begin : n_ubx    assign n_ub  = '1;                   end
  assign o = v_hex;
endmodule
