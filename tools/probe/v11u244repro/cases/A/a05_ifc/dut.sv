// § hpSelIdxPathTrailByChain244
interface bus_if; logic [7:0] mem [4]; logic [1:0] idx; endinterface
typedef struct packed { logic [1:0] k; } ix_t;
module top(input ix_t t, input logic [7:0] d, output logic [7:0] y, output logic [7:0] y2);
  bus_if b();
  always_comb for (int i = 0; i < 4; i++) b.mem[i] = d ^ i;
  assign b.idx = t.k;
  assign y = b.mem[t.k];
  assign y2 = b.mem[b.idx];
endmodule
