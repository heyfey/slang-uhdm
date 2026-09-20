// v11u69 v5 — DEAD generate arms and the def view.  A false gen-if arm, an
// unselected gen-case arm and a zero-trip gen-for must emit NOTHING elaborated;
// the DEF listing still carries the written syntax on both sides.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 77};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT, parameter int SEL = 2)
  (input  logic a_i,
   output logic [31:0] o_live, o_dead, o_case, o_zero);

  if (0) begin : dead
    assign o_dead = CFG.n;          // DEAD: never elaborated
  end else begin : alive
    assign o_dead = 32'd1;
  end

  if (1) begin : live
    assign o_live = CFG.n;          // LIVE
  end

  case (SEL)
    1: begin : c1
      assign o_case = CFG.n;        // NOT selected
    end
    2: begin : c2
      assign o_case = CFG.n;        // selected
    end
    default: begin : cd
      assign o_case = 32'd0;
    end
  endcase

  for (genvar k = 0; k < 0; k++) begin : zero
    assign o_zero = CFG.n;          // zero-trip
  end
  assign o_zero = 32'd0;
endmodule
