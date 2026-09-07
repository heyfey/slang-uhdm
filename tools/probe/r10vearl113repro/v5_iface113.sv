// r10vearl113 (VERIFIER) arm v5 -- THE SCOPE-KIND AXIS beyond module_inst:
// an INTERFACE's generate block, and a generate block of a module instantiated
// under an interface.  MEASUREMENT ONLY.
//   f1  gen-local pattern target inside an INTERFACE's generate block
//   f2  interface-body target written from that same generate block (fence)
//   f3  a plain module-scope twin, so the arm carries its own control
package pv5113;
  typedef enum logic [2:0] { ZA = 3'h0, ZB = 3'h4 } ze_e;
  typedef struct packed {
    logic       v;
    ze_e        o;
    logic [7:0] d;
  } zs_t;
endpackage

interface v5_if113 #(parameter int K = 2) (input logic clk);
  logic [7:0] d_i;
  pv5113::zs_t src;
  // f1  GEN-LOCAL target inside an interface generate block
  for (genvar i = 0; i < K; i++) begin : gen_if_loc
    pv5113::zs_t f1_loc;
    assign f1_loc = '{ v: src.v, o: src.o, d: d_i };
  end
  // f2  INTERFACE-BODY target written from a generate block
  pv5113::zs_t f2_mod;
  if (K > 0) begin : gen_if_mod
    assign f2_mod = '{ v: src.v, o: src.o, d: d_i };
  end
  // f3  the interface-scope twin
  pv5113::zs_t f3_body;
  assign f3_body = '{ v: src.v, o: src.o, d: d_i };
endinterface

module v5_iface113 (input logic clk, output logic y_o);
  v5_if113 #(.K(2)) u_if (.clk(clk));
  assign y_o = u_if.f2_mod.v ^ u_if.f3_body.v;
endmodule
