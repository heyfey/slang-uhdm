// r11u69 g1 — GENERATE KINDS.  One Rhs (`CFG.n`, a struct-param field read
// reaching its pattern through a package localparam = the W1 chain), one Lhs
// kind (plain 32-bit net), six homes: module level (control, already folded by
// § caStructParamPatternSubst55), gen-for, named gen-if TRUE arm, gen-if ELSE
// arm, gen-case, and an UNNAMED gen-if.
package p;
  typedef struct packed { int unsigned n; logic [7:0] w; } cfg_t;
  localparam cfg_t LIT = '{n: 3, w: 8'hA5};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT, parameter int SEL = 1)
  (input  logic        a_i,
   output logic [31:0] o_top,
   output logic [31:0] o_for,
   output logic [31:0] o_if,
   output logic [31:0] o_els,
   output logic [31:0] o_case,
   output logic [31:0] o_unn);

  assign o_top = CFG.n;                       // CONTROL: module level

  for (genvar k = 0; k < 1; k++) begin : gfor
    assign o_for = CFG.n;
  end

  if (1) begin : gif
    assign o_if = CFG.n;
  end

  if (0) begin : gift
    assign o_els = 32'd0;
  end else begin : gels
    assign o_els = CFG.n;
  end

  case (SEL)
    1: begin : gcase
      assign o_case = CFG.n;
    end
    default: begin : gcased
      assign o_case = 32'd0;
    end
  endcase

  if (1) begin
    assign o_unn = CFG.n;
  end
endmodule
