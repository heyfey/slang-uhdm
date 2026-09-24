typedef struct packed { logic [1:0] p; logic g; } pte_t;
module dut(input logic [11:0] i, output logic [11:0] o);
  struct packed { pte_t pte; pte_t gpte; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
