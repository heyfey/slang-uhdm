package cp;
  typedef struct packed { logic [3:0] x; logic [3:0] z; } in_t;
  typedef struct packed { logic [7:0] f; in_t n; logic [7:0] g; } s_t;
  localparam s_t CFG = '{f: 8'hA5, n: '{x: 4'h9, z: 4'h6}, g: 8'h3C};
  parameter s_t PCFG = '{f: 8'h5A, n: '{x: 4'h1, z: 4'h2}, g: 8'hC3};
endpackage
module top (input logic [7:0] d, output logic [3:0] o);
  localparam logic [3:0] L = cp::CFG.f[3:0];
  localparam logic [3:0] M = cp::CFG.n.x;
  assign o = L ^ M ^ cp::CFG.f[7:4];
endmodule
