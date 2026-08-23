// r10v76 arm a1 -- THE HOME GRID the implementer's g1 does not cover.
// One wildcard-imported package parameter read from a for CONDITION, a for
// BODY, a while CONDITION and a repeat COUNT, in homes g1 never builds:
// an INTERFACE generate scope, a PROGRAM generate scope, a gen-FOR nested
// inside a gen-IF, a TASK declared in a generate block, a nested gen at
// depth 3, and the same module instantiated THREE times.
package v76p;
  parameter int NB = 4;
endpackage

interface v76if #(parameter int P = 1) (input logic clk);
  import v76p::*;
  logic [31:0] q1, q2;
  if (P > 0) begin : gi_a                       // INTERFACE gen-if home
    always_comb begin
      q1 = '0;
      for (int i = 0; i < NB; i++) q1 = q1 + {NB{1'b1}};
      repeat (NB) q1 = q1 + 1;
    end
  end
  for (genvar g = 0; g < 2; g++) begin : gi_b   // INTERFACE gen-for home
    always_comb begin
      q2 = '0;
      for (int i = 0; i < NB; i++) q2 = q2 + 1;
    end
  end
endinterface

program v76pg #(parameter int P = 1) (input logic clk);
  import v76p::*;
  int p1;
  if (P > 0) begin : gp_a                       // PROGRAM gen-if home
    initial begin
      p1 = 0;
      for (int i = 0; i < NB; i++) p1 = p1 + 1;
      repeat (NB) p1 = p1 + 1;
    end
  end
endprogram

module v76m #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  import v76p::*;
  logic [31:0] h1, h2, h3, h4, h5;

  // gen-FOR nested inside a gen-IF  (depth 2 -> law 24 territory: control)
  if (P > 0) begin : gh_a
    for (genvar g = 0; g < 2; g++) begin : gh_aa
      always_comb begin
        h1 = '0;
        for (int i = 0; i < NB; i++) h1 = h1 + 1;
      end
    end
  end

  // a TASK declared in a generate block, called from a gen-scope process
  if (P > 0) begin : gh_b
    task automatic tk(output logic [31:0] y);
      y = '0;
      for (int i = 0; i < NB; i++) y = y + 1;
      repeat (NB) y = y + 1;
    endtask
    always_comb tk(h2);
  end

  // NESTED gen at DEPTH 3
  if (P > 0) begin : gh_c
    if (P > 1) begin : gh_cc
      if (P > 1) begin : gh_ccc
        always_comb begin
          h3 = '0;
          for (int i = 0; i < NB; i++) h3 = h3 + 1;
        end
      end
    end
  end

  // a gen-scope always with a WHILE control and a for INSIDE the while body
  if (P > 0) begin : gh_d
    always_comb begin
      int w; w = 0; h4 = '0;
      while (w < NB) begin                       // while CONDITION
        for (int i = 0; i < NB; i++) h4 = h4 + 1; // for inside a WHILE BODY
        h4 = h4 + NB;                            // plain stmt in a while body
        w = w + 1;
      end
    end
  end

  // a WHILE inside a FOR BODY: the for region swallows the while body too
  if (P > 0) begin : gh_e
    always_comb begin
      h5 = '0;
      for (int i = 0; i < 2; i++) begin
        int w2; w2 = 0;
        while (w2 < NB) begin h5 = h5 + NB; w2 = w2 + 1; end
      end
    end
  end

  assign o = h1 ^ h2 ^ h3 ^ h4 ^ h5;
endmodule

module v76top (input logic clk,
               output logic [31:0] o1, output logic [31:0] o2,
               output logic [31:0] o3);
  v76if #(1) u_if (.clk(clk));
  v76pg #(1) u_pg (.clk(clk));
  v76m  #(2) u_m0 (.clk(clk), .o(o1));   // THREE instances of the same module
  v76m  #(2) u_m1 (.clk(clk), .o(o2));
  v76m  #(3) u_m2 (.clk(clk), .o(o3));
endmodule
