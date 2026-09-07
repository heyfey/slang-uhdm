// r10earl119 a2_fence119 — THE FENCES, as shapes this law MUST NOT MOVE, and
// the RESIDUE shapes it deliberately declines (a cast whose operand is not
// already a constant).  Every row is measured against the GOLDEN default-view
// database; a fence row is one where golden and the PRISTINE binary already
// agree.  MEASUREMENT ONLY.
package pa2_119;
  parameter int unsigned W8 = 8;
  parameter int unsigned P63 = 63;
endpackage

module a2_fence119 (output logic [7:0] o);
  localparam int unsigned LW = 8;
  logic [7:0] f_byte, f_logic, f_zz;          // casts with no ExprEval branch
  logic [7:0] f_cat, f_rep, f_bop, f_ter, f_sysc, f_nest;  // non-constant operands
  logic [7:0] f_lit, f_par, f_catr, f_ub;     // NON-cast Rhs (other laws)
  logic [7:0] f_mod;                          // module-body cont_assign
  logic [7:0] f_sel;                          // select targets
  logic [7:0] f_proc;

  // --- casts with NO `ExprEval` `vpiCastOp` branch: golden keeps op67 ---
  if (1) begin : f_bytex  assign f_byte  = byte'(6'h3F);            end
  if (1) begin : f_logicx assign f_logic = logic'(6'h3F);           end
  // --- a cast whose operand `get_value` cannot read: golden keeps op67 ---
  if (1) begin : f_zzx    assign f_zz    = 8'(6'bzzzzzz);           end

  // --- casts over a NON-CONSTANT operand.  Golden FOLDS these; this law
  //     declines them (R1), so the pristine and patched answers must be the
  //     SAME wrong one, never a NEW wrong one. ---
  if (1) begin : f_catx   assign f_cat   = 8'({2'b11,4'hF});        end
  if (1) begin : f_repx   assign f_rep   = 8'({6{1'b1}});           end
  if (1) begin : f_bopx   assign f_bop   = 8'(60 + 3);              end
  if (1) begin : f_terx   assign f_ter   = 8'(LW==8 ? 63 : 1);      end
  if (1) begin : f_sysx   assign f_sysc  = 8'($clog2(64));          end
  if (1) begin : f_nestx  assign f_nest  = 8'(4'(6'h3F));           end

  // --- NON-cast Rhs shapes: other laws own these encodings entirely ---
  if (1) begin : f_litx   assign f_lit   = 6'h3F;                   end
  if (1) begin : f_parx   assign f_par   = pa2_119::P63;            end
  if (1) begin : f_catrx  assign f_catr  = {2'b11,4'hF};            end
  if (1) begin : f_ubx    assign f_ub    = '1;                      end

  // --- select targets: bindVariable never runs on them ---
  if (1) begin : f_selx   assign f_sel[3]   = pa2_119::W8'(6'h3F);  end
  if (1) begin : f_selpx  assign f_sel[7:4] = pa2_119::W8'(6'h3F);  end

  // --- a PROCEDURAL cast assignment in a gen scope: not a cont_assign ---
  if (1) begin : f_procx  always_comb f_proc = pa2_119::W8'(6'h3F); end

  // --- a MODULE-BODY cont_assign with a cast: already right on both sides,
  //     and out of the walk's reach (gen scopes only) ---
  assign f_mod = pa2_119::W8'(6'h3F);

  assign o = f_byte ^ f_logic ^ f_zz ^ f_cat ^ f_rep ^ f_bop ^ f_ter ^
             f_sysc ^ f_nest ^ f_lit ^ f_par ^ f_catr ^ f_ub ^ f_sel ^
             f_proc ^ f_mod;
endmodule
