// ps23.sv — THE SELECT-LHS QUARTER of § genCaOpDeepBindGenLocal20, measured
// in a CHILD INSTANCE.  ps20 isolated the LHS as that law's discriminator with
// three rows whose LHS is either a gen-local or a WHOLE module net; a SELECT
// LHS was never measured, and the whole-arena bind census over Earlgrey says
// the select-LHS rows are the single largest bind residue left (864
// `G=logic_var O=-` rows over four scopes, every one of them a SELECT LHS over
// a MODULE-level signal, every one of them inside a CHILD instance):
//   rv_plic_target.sv:101-103    assign is_tree[Pa] = (sel & is_tree[C1]) | ..
//   prim_arbiter_tree.sv:146-152 assign idx_tree[Pa] = ({N{sel}} & ..) | ..
//   pinmux.sv:181-182            assign mio_out_o[k] = (sleep_en) ? .. : ..
//   ibex_wb_stage.sv:99          assign rf_wdata_wb_mux_we[0] = rf_we_wb_q & ..
// A TOP-module version of this file measures the OPPOSITE way round (we
// over-bind there), which is pass 22's child-instance trap all over again.
typedef struct packed { logic [3:0] f; logic [3:0] gg; } str_t;

module ps23_child (
    input  logic [3:0] a,
    input  logic       c,
    output logic [3:0] y1,
    output logic [3:0] y2,
    output logic [3:0] msel [2],
    output logic [3:0] msel2 [2],
    output logic [3:0] msel3 [2],
    output logic [7:0] mpart,
    output str_t       mstr
);

  for (genvar k = 0; k < 1; k++) begin : g
    logic [3:0] v1;
    always_comb v1 = a;

    logic [3:0] s1;
    assign s1        = v1 ^ 4'h5;      // S1 LHS gen-local  (ps20: BOUND)
    assign y1        = v1 ^ 4'h5;      // S2 LHS module net (ps20: unbound)
    assign y2        = v1;             // S3 LHS module net, whole ref (BOUND)
    assign msel[0]   = v1 ^ 4'h5;      // S4 LHS ELEMENT SELECT, operation
    assign msel[1]   = v1;             // S5 LHS ELEMENT SELECT, whole ref
    assign msel2[0]  = c ? v1 : 4'h0;  // S6 LHS ELEMENT SELECT, ternary arm
    assign mpart[3:0] = v1 ^ 4'h5;     // S7 LHS PART SELECT, operation
    assign mstr.f     = v1 ^ 4'h5;     // S8 LHS MEMBER ACCESS, operation
  end

  for (genvar k = 0; k < 1; k++) begin : go
    logic [3:0] vouter;
    always_comb vouter = a;
    if (1) begin : gi
      assign msel3[0] = vouter ^ 4'h5; // N1 select LHS, ANCESTOR-scope local
    end
  end

endmodule

module ps23 (
    input  logic [3:0] a,
    input  logic       c,
    output logic [3:0] y1,
    output logic [3:0] y2,
    output logic [3:0] msel [2],
    output logic [3:0] msel2 [2],
    output logic [3:0] msel3 [2],
    output logic [7:0] mpart,
    output str_t       mstr
);
  ps23_child u_c (.a(a), .c(c), .y1(y1), .y2(y2), .msel(msel),
                  .msel2(msel2), .msel3(msel3), .mpart(mpart), .mstr(mstr));
endmodule
