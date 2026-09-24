package cp;
  typedef struct packed { logic [3:0] x; logic [3:0] z; } in_t;
  typedef struct packed { logic [7:0] f; in_t n; logic [7:0] g; } s_t;
  localparam s_t CFG = '{f: 8'hA5, n: '{x: 4'h9, z: 4'h6}, g: 8'h3C};
  parameter s_t PCFG = '{f: 8'h5A, n: '{x: 4'h1, z: 4'h2}, g: 8'hC3};
endpackage
module sub #(parameter logic [3:0] P = 0) (output logic [3:0] o); assign o = P; endmodule
module top (output logic [3:0] o);
  sub #(.P(cp::CFG.f[3:0])) u (.o(o));
endmodule
