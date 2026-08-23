// r10earl76 arm g1 -- THE POSITION GRID.  One wildcard-imported package
// parameter (`parameter int NB`) read from EVERY position a process statement
// offers, in SEVEN homes.  Question 2 asks which of those positions golden
// refuses to substitute inside a GENERATE SCOPE; row A is the MODULE-BODY
// positive control that must not move.
//
// Position codes (they appear in the census ROUTE as for:c / whl:c / ...):
//   P1  for INIT rhs        P2  for CONDITION      P3  for STEP
//   P4  for BODY            P5  while CONDITION    P6  while BODY
//   P7  do-while CONDITION  P8  do-while BODY      P9  repeat COUNT
//   P10 repeat BODY         P11 foreach BODY       P12 if CONDITION
//   P13 case ITEM           P14 plain statement    P15 nested for CONDITION
package g76p;
  parameter int NB = 4;
endpackage

// ---------------------------------------------------------------- row A
// MODULE BODY.  golden FOLDS every one of these (measured); the whole row is
// the negative control of this pass.
module g76body (output logic [31:0] o);
  import g76p::*;
  logic [31:0] a1, a2, a3, a4, a5;
  logic [7:0] mem [0:3];
  always_comb begin
    a1 = '0;
    for (int i = NB - 3; i < NB; i = i + NB) a1 = a1 + {NB{1'b1}};
  end
  always_comb begin
    int w; w = 0; a2 = '0;
    while (w < NB) begin a2 = a2 + {NB{1'b1}}; w = w + 1; end
  end
  always_comb begin
    int d; d = 0; a3 = '0;
    do begin a3 = a3 + {NB{1'b1}}; d = d + 1; end while (d < NB);
  end
  always_comb begin
    a4 = '0;
    repeat (NB) a4 = a4 + {NB{1'b1}};
    foreach (mem[k]) a4 = a4 + {NB{1'b1}};
  end
  always_comb begin
    a5 = '0;
    if (NB > 1) a5 = a5 + 1;
    case (a5)
      NB + 0: a5 = a5 + 2;
      default: a5 = a5 + 3;
    endcase
    a5 = a5 + {NB{1'b1}};
    for (int i = 0; i < 2; i++)
      for (int j = 0; j < NB; j++) a5 = a5 + 1;
  end
endmodule

// ---------------------------------------------------------------- rows B..F
module g76gen #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  import g76p::*;
  logic [31:0] b1, b2, b3, b4, b5, c1, d1, e1, f1;
  logic [7:0] mem [0:3];

  // row B -- gen-IF block, always_comb, the whole position sweep
  if (P > 0) begin : gen_b
    always_comb begin
      b1 = '0;
      for (int i = NB - 3; i < NB; i = i + NB) b1 = b1 + {NB{1'b1}};   // P1..P4
    end
    always_comb begin
      int w; w = 0; b2 = '0;
      while (w < NB) begin b2 = b2 + {NB{1'b1}}; w = w + 1; end        // P5,P6
    end
    always_comb begin
      int d; d = 0; b3 = '0;
      do begin b3 = b3 + {NB{1'b1}}; d = d + 1; end while (d < NB);    // P7,P8
    end
    always_comb begin
      b4 = '0;
      repeat (NB) b4 = b4 + {NB{1'b1}};                                // P9,P10
      foreach (mem[k]) b4 = b4 + {NB{1'b1}};                           // P11
    end
    always_comb begin
      b5 = '0;
      if (NB > 1) b5 = b5 + 1;                                         // P12
      case (b5)
        NB + 0: b5 = b5 + 2;                                           // P13
        default: b5 = b5 + 3;
      endcase
      b5 = b5 + {NB{1'b1}};                                            // P14
      for (int i = 0; i < 2; i++)
        for (int j = 0; j < NB; j++) b5 = b5 + 1;                      // P15
    end
  end

  // row C -- gen-FOR block (two iterations)
  for (genvar g = 0; g < 2; g++) begin : gen_c
    always_comb begin
      c1 = '0;
      for (int i = NB - 3; i < NB; i = i + NB) c1 = c1 + {NB{1'b1}};
      repeat (NB) c1 = c1 + 1;
    end
  end

  // row D -- gen-scope always_ff
  if (P > 0) begin : gen_d
    always_ff @(posedge clk) begin
      d1 <= '0;
      for (int i = 0; i < NB; i++) d1 <= d1 + {NB{1'b1}};
    end
  end

  // row E -- gen-scope INITIAL (fence (a) of earl75: no instance at all)
  if (P > 0) begin : gen_e
    initial begin
      e1 = '0;
      for (int i = 0; i < NB; i++) e1 = e1 + {NB{1'b1}};
      repeat (NB) e1 = e1 + 1;
    end
  end

  // row F -- gen-scope FUNCTION body (a subroutine, not a process)
  if (P > 0) begin : gen_f
    function automatic [31:0] gf(input [31:0] x);
      logic [31:0] t;
      t = x;
      for (int i = 0; i < NB; i++) t = t + {NB{1'b1}};
      repeat (NB) t = t + 1;
      return t;
    endfunction
    always_comb f1 = gf(32'd1);
  end

  // row G -- NESTED gen block
  if (P > 0) begin : gen_g
    if (P > 1) begin : gen_gg
      logic [31:0] g1;
      always_comb begin
        g1 = '0;
        for (int i = 0; i < NB; i++) g1 = g1 + {NB{1'b1}};
      end
    end
  end

  assign o = b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ c1 ^ d1 ^ e1 ^ f1;
endmodule

module g76top (input logic clk, output logic [31:0] o1, output logic [31:0] o2);
  g76body u_b (.o(o1));
  g76gen #(2) u_g (.clk(clk), .o(o2));
endmodule
