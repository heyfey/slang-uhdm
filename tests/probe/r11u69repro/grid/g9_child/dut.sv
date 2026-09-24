// r11u69 g9 — THE GENERATE BLOCK LIVES IN A CHILD INSTANCE, and the struct
// parameter arrives through an OVERRIDE.  (RESUME §9's child-instance trap:
// the top module's unsuppressed path can hide a gap.)  Two instances of the
// same leaf with DIFFERENT overrides measure the per-instance clone.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t A = '{n: 3};
  localparam cfg_t B = '{n: 8};
endpackage

module leaf #(parameter p::cfg_t C = p::A)
  (input logic a_i, output logic [31:0] o_g, output logic [31:0] o_t);
  assign o_t = C.n;                    // CONTROL: module level
  for (genvar k = 0; k < 1; k++) begin : gk
    assign o_g = C.n;
  end
endmodule

module dut (input logic a_i,
            output logic [31:0] oa_g, oa_t, ob_g, ob_t);
  leaf #(.C(p::A)) u_a (.a_i(a_i), .o_g(oa_g), .o_t(oa_t));
  leaf #(.C(p::B)) u_b (.a_i(a_i), .o_g(ob_g), .o_t(ob_t));
endmodule
