// v111 adversarial arm A4 -- THE AWAY HUNT.  Every shape I could construct in
// which a MODULE-scope parameter declared `int` reaches the width half of a
// dotted indexed part-select through a path where Surelog might NOT give the
// parameter a typespec: a parameter PORT LIST entry overridden at the
// instantiation, a generate-IF body, a nested generate-for, a parameter read
// through a module HIERARCHY, a `program` block, and a localparam whose value
// comes from another parameter of the same module.
package pk4v111;
  typedef struct packed { logic [63:0] src; logic v; } h_t;
endpackage

module inner4v111 #(parameter int PW = 2)
                   (input pk4v111::h_t h_i, output logic [63:0] o);
  localparam int unsigned FROMP = PW;      // localparam FROM a port parameter
  logic [63:0] r;
  for (genvar gi = 0; gi < 1; gi++) begin : gi1
    assign r[1:0] = h_i.src[0 +: FROMP];
    assign r[3:2] = h_i.src[0 +: PW];      // the PORT parameter itself
  end
  assign o = r;
endmodule

module s4v111 #(parameter int TOPW = 2, localparam int PLL = 2)
               (input pk4v111::h_t h_i, output logic [63:0] o);
  localparam int unsigned BODY = 2;
  logic [63:0] r, ro;
  inner4v111 #(.PW(TOPW)) u_in (.h_i(h_i), .o(ro));
  for (genvar gi = 0; gi < 1; gi++) begin : gf
    if (TOPW == 2) begin : gif
      localparam int unsigned INIF = 2;    // generate-IF body localparam
      assign r[1:0] = h_i.src[0 +: INIF];
      assign r[3:2] = h_i.src[0 +: BODY];  // outer localparam, inside gen-if
      assign r[5:4] = h_i.src[0 +: PLL];   // parameter-port-list localparam
      assign r[7:6] = h_i.src[0 +: TOPW];  // OVERRIDABLE port parameter
    end
  end
  assign o = r ^ ro;
endmodule

module vA4_bare111;
  pk4v111::h_t s;
  logic [63:0] o1, o2;
  s4v111 #(.TOPW(2)) u1 (.h_i(s), .o(o1));
  s4v111 #(.TOPW(2)) u2 (.h_i(s), .o(o2));
endmodule
