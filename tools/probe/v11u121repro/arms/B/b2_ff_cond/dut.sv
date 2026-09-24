package cp;
  typedef struct packed { logic [3:0] x; logic [3:0] z; } in_t;
  typedef struct packed { logic [7:0] f; in_t n; logic [7:0] g; } s_t;
  localparam s_t CFG = '{f: 8'hA5, n: '{x: 4'h9, z: 4'h6}, g: 8'h3C};
  parameter s_t PCFG = '{f: 8'h5A, n: '{x: 4'h1, z: 4'h2}, g: 8'hC3};
endpackage
module top (input logic clk, input logic [7:0] d, output logic [7:0] q);
  always_ff @(posedge clk) if (cp::CFG.f[2]) q <= d; else q <= ~d;
endmodule
