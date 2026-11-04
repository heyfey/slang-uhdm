// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [1:0] k; logic [1:0] j; } ix_t;
typedef struct packed { logic [15:0] d; } dat_t;
module top #(parameter ix_t P = '{k:2'd1, j:2'd2}) (input dat_t s, output logic [1:0] y, output logic [3:0] y2, output logic y3);
  localparam ix_t L = '{k:2'd3, j:2'd0};
  assign y = s.d[P.k +: 2];
  assign y2 = s.d[L.k*4 +: 4];
  assign y3 = s.d[P.j];
endmodule
