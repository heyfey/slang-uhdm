// r10v75 arm a2 -- LOOP KINDS other than for-stmt inside a gen-scope process:
// foreach / while / do-while / repeat.  procForAllDepth9 fences ONLY for-stmts;
// if golden keeps the ref_obj in these too, the patch stamps a constant golden
// does not have.
package a2p;
  parameter int NB = 4;
endpackage

module a2m #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  import a2p::*;
  logic [31:0] r0, r1, r2, r3, r4;
  logic [7:0] mem [0:3];
  if (P > 0) begin : gen_b
    always_comb begin                       // A2_P1 foreach
      r0 = '0;
      foreach (mem[k])
        r0 = r0 + {NB{1'b1}};
    end
    always_comb begin                       // A2_P2 while
      int w; w = 0; r1 = '0;
      while (w < NB) begin
        r1 = r1 + 1;
        w = w + 1;
      end
    end
    always_comb begin                       // A2_P3 do-while
      int d; d = 0; r2 = '0;
      do begin
        r2 = r2 + {NB{1'b1}};
        d = d + 1;
      end while (d < NB);
    end
    always_comb begin                       // A2_P4 repeat
      r3 = '0;
      repeat (NB) r3 = r3 + 1;
    end
    always_comb begin                       // A2_P5 for-stmt (fenced control)
      r4 = '0;
      for (int i = 0; i < NB; i++)
        r4 = r4 + {NB{1'b1}};
    end
  end
  assign o = r0 ^ r1 ^ r2 ^ r3 ^ r4;
endmodule

module a2body (input logic clk, output logic [31:0] o);
  import a2p::*;
  logic [31:0] r0, r1, r2, r3, r4;
  logic [7:0] mem [0:3];
  always_comb begin                         // A2_B1 module-body foreach control
    r0 = '0;
    foreach (mem[k]) r0 = r0 + {NB{1'b1}};
  end
  always_comb begin
    int w; w = 0; r1 = '0;
    while (w < NB) begin r1 = r1 + 1; w = w + 1; end
  end
  always_comb begin
    int d; d = 0; r2 = '0;
    do begin r2 = r2 + {NB{1'b1}}; d = d + 1; end while (d < NB);
  end
  always_comb begin r3 = '0; repeat (NB) r3 = r3 + 1; end
  always_comb begin r4 = '0; for (int i = 0; i < NB; i++) r4 = r4 + {NB{1'b1}}; end
  assign o = r0 ^ r1 ^ r2 ^ r3 ^ r4;
endmodule

module a2top (input logic clk, output logic [31:0] o1, output logic [31:0] o2);
  a2m #(2) u_a (.clk(clk), .o(o1));
  a2body  u_b (.clk(clk), .o(o2));
endmodule
