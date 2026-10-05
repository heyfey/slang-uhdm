// § hpSelIdxPathTrailByChain244
typedef struct packed { logic [1:0] k; } ix_t;
typedef struct { logic [7:0] v [4]; } arr_t;
module top #(parameter int M = 1) (input ix_t t, input logic [7:0] d, output logic [7:0] y, output logic [7:0] y2);
  arr_t s;
  always_comb for (int i = 0; i < 4; i++) s.v[i] = d + i;
  if (M == 1) begin : g_if
    ix_t u;
    assign u = t;
    assign y = s.v[u.k];
  end else begin : g_else
    assign y = s.v[t.k];
  end
  case (M)
    1: begin : g_c1 assign y2 = s.v[t.k] ^ s.v[g_if.u.k]; end
    default: begin : g_cd assign y2 = '0; end
  endcase
endmodule
