// r11u74 a1 — LAW A: the FUNCTION-BUILT struct parameter's member select as
// the whole Rhs of a cont_assign, written once at MODULE level and once in
// each generate kind.  § caAsmMemberSliceFold serves the module-level row;
// the question is what golden writes for the generate twins.
package p;
  typedef struct packed { int unsigned n; int unsigned m; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.n = x;
    c.m = $clog2(x / 8);
    return c;
  endfunction
  localparam cfg_t BUILT = build(64);
endpackage
module dut #(parameter p::cfg_t FB = p::BUILT)
  (input logic sel_i,
   output logic [31:0] t_mod, g_for, g_if, g_else, g_case, g_nest, g_anon);
  assign t_mod = FB.n;                       // module level (the served row)
  for (genvar i = 0; i < 1; i = i + 1) begin : gf
    assign g_for = FB.n;
  end
  if (1) begin : gi
    assign g_if = FB.n;
  end else begin : ge
    assign g_else = FB.m;
  end
  case (1)
    1: begin : gc
      assign g_case = FB.n;
    end
  endcase
  if (1) begin : gn
    for (genvar j = 0; j < 1; j = j + 1) begin : gn2
      assign g_nest = FB.m;
    end
  end
  if (1) begin
    assign g_anon = FB.n;
  end
endmodule
