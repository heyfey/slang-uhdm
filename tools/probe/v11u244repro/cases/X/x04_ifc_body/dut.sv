// § lvHpIpsOperandChain244
typedef struct packed { logic [31:0] d; } dat_t;
typedef struct packed { logic [1:0] k; } ix_t;
interface bus_if(input logic clk);
  dat_t s; ix_t t; logic [7:0] mem [4]; logic [7:0] o;
  always_ff @(posedge clk) s.d[t.k*8 +: 8] <= mem[t.k];
  assign o = mem[t.k];
  modport m(input s, output o);
endinterface
module top(input logic clk, output logic [7:0] y, output dat_t z);
  bus_if b(clk);
  assign y = b.o;
  assign z = b.s;
endmodule
