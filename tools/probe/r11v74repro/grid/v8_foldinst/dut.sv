// v11u74 v8 — LAW A ACROSS INSTANCES: the same generate-scope member read in
// two elaborations of one module with DIFFERENT parameter values.  The record
// is keyed on the ParameterSymbol; if the two elaborations share one, both
// cells take one instance's bits.
package p;
  typedef struct packed { int unsigned n; int unsigned m; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.n = x;
    c.m = x + 1;
    return c;
  endfunction
endpackage
module leaf #(parameter int unsigned W = 64,
              parameter p::cfg_t FB = p::build(W))
  (output logic [31:0] o);
  logic [31:0] g_out, m_out;
  assign m_out = FB.n;
  if (1) begin : gb
    assign g_out = FB.n;
  end
  assign o = g_out ^ m_out;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] a, b;
  leaf #(.W(64))  u0 (.o(a));
  leaf #(.W(128)) u1 (.o(b));
  assign o = a ^ b;
endmodule
