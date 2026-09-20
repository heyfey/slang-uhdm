// r11v69 w5 — THREE instances of the same leaf, THREE different overrides, the
// generate-scope assignment targeting a module-body variable of the leaf.  The
// producer clones per ELABORATED instance, so the three databases must carry
// three DIFFERENT values; a shared source object would give one.  A defaulted
// fourth instance reads the default.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t D = '{n: 1};
  localparam cfg_t A = '{n: 11};
  localparam cfg_t B = '{n: 22};
  localparam cfg_t C = '{n: 33};
endpackage

module leaf #(parameter p::cfg_t K = p::D)
  (input logic a_i, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gl
    assign mv = K.n;
  end
  assign o = mv;
endmodule

module dut (input logic a_i, output logic [31:0] oa, ob, oc, od);
  leaf #(.K(p::A)) ua (.a_i(a_i), .o(oa));
  leaf #(.K(p::B)) ub (.a_i(a_i), .o(ob));
  leaf #(.K(p::C)) uc (.a_i(a_i), .o(oc));
  leaf             ud (.a_i(a_i), .o(od));
endmodule
