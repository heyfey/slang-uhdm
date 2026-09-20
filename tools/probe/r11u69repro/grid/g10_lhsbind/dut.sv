// r11u69 g10 — THE COMPOSE CELL WITH § genCaConstRhsLhsNoBind25.  That law
// reads the INSTALLED Rhs: once this pass substitutes a constant, a cont_assign
// whose Lhs is the generate block's OWN local loses its `vpiActual`.  Golden is
// the arbiter — the producer clones the assign at the substitution, so the
// clone's Lhs ref is expected to come back unbound for an own-scope local and
// bound for everything else.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 3};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input  logic        a_i,
   output logic [31:0] o_mod,
   output logic [31:0] o_anc,
   output logic [31:0] o_name,
   output logic [31:0] o_net);

  logic [31:0] m_var;      // module-body variable
  logic [31:0] nm;         // the NAMESAKE of a gen-local below

  if (1) begin : gown
    logic [31:0] lv;       // the block's OWN local  -> expect UNBOUND
    assign lv = CFG.n;
    assign o_mod = lv;
  end

  if (1) begin : ganc
    logic [31:0] av;       // declared one gen level UP
    if (1) begin : ganci
      assign av = CFG.n;   // ANCESTOR gen scope's local -> expect BOUND
    end
    assign o_anc = av;
  end

  if (1) begin : gname
    logic [31:0] nm;       // own local SHADOWING a module-body name
    assign nm = CFG.n;
    assign o_name = nm;
  end

  if (1) begin : gnet
    wire [31:0] wv;        // a gen-local NET, not a variable
    assign wv = CFG.n;
    assign o_net = wv;
  end
endmodule
