// r10v67 verifier arm 3 — the HOME grid.  A one-hop gen-scope localparam read
// as a bit-select index from: a generate-CASE body, an UNNAMED generate block,
// a NAMED begin block inside a gen scope (the earl47 F1 refusal), an
// ALWAYS_COMB in a gen scope, a nested gen scope 1/2/3 deep, an INTERFACE's
// own generate scope, a gen scope inside a CHILD instance (2 instances, 3
// unrollings each, different parameter values), and a gen scope reading a
// localparam of the SAME NAME declared in a DIFFERENT gen instance.
interface v3if67 (input logic clk);
  logic [15:0] bus;
  for (genvar q = 0; q < 2; q++) begin : iA
    localparam int unsigned Kq = q + 1;
    if (1) begin : iB
      logic ib;
      assign ib = bus[Kq];
    end
  end
endinterface

module v3child67 #(parameter int unsigned CW = 1) (input logic [15:0] a,
                                                   output logic [15:0] z);
  for (genvar g = 0; g < 3; g++) begin : cA
    localparam int unsigned Kc = g + CW;
    if (1) begin : cB
      logic cb;
      assign cb = a[Kc];
      assign z[g] = cb;
    end
    // generate-CASE home
    case (g)
      0: begin : cCase0
        logic cc;
        assign cc = a[Kc];
        assign z[3+g] = cc;
      end
      default: begin : cCaseD
        logic cd;
        assign cd = a[Kc];
        assign z[3+g] = cd;
      end
    endcase
    // UNNAMED generate block one hop down
    if (1) begin
      logic cu;
      assign cu = a[Kc];
      assign z[6+g] = cu;
    end
    // a NAMED BEGIN block (not a generate block) inside the same gen scope
    always_comb begin : nb
      z[9+g] = a[Kc];
    end
  end
  assign z[15:12] = '0;
endmodule

module v3_homes67 (input logic clk, input logic [15:0] d, output logic [15:0] y);
  logic [15:0] z1, z2;
  v3if67 u_if (.clk(clk));
  v3child67 #(.CW(1)) u_c1 (.a(d), .z(z1));
  v3child67 #(.CW(2)) u_c2 (.a(d), .z(z2));
  assign y = z1 ^ z2;
endmodule
