// r11u69 g5 — NESTING.  gen-if inside gen-for, gen-for inside gen-for,
// gen-if inside gen-if, three levels deep.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 5};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic        a_i,
   output logic [31:0] o_if_in_for,
   output logic [31:0] o_for_in_for [0:1],
   output logic [31:0] o_if_in_if,
   output logic [31:0] o_deep3);

  for (genvar k = 0; k < 1; k++) begin : lvl1f
    if (1) begin : lvl2i
      assign o_if_in_for = CFG.n;
    end
  end

  for (genvar k = 0; k < 1; k++) begin : outf
    for (genvar j = 0; j < 2; j++) begin : innf
      assign o_for_in_for[j] = CFG.n;
    end
  end

  if (1) begin : oi
    if (1) begin : ii
      assign o_if_in_if = CFG.n;
    end
  end

  if (1) begin : d1
    for (genvar k = 0; k < 1; k++) begin : d2
      if (1) begin : d3
        assign o_deep3 = CFG.n;
      end
    end
  end
endmodule
