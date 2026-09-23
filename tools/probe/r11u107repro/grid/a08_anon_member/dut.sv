typedef struct packed {
  struct packed { logic a; logic b; } [1:0] m;
  logic c;
} t_t;
module dut(input logic [4:0] i, output logic [4:0] o);
  t_t x;
  assign x = i;
  assign o = x;
endmodule
