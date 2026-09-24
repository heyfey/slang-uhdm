module top (input logic s, input logic [2:0] k, output logic [7:0] o);
  typedef struct packed { logic [7:0] f; logic [7:0] g; } l_t;
  localparam l_t LCFG = '{f: 8'h3C, g: 8'hC3};
  assign o = LCFG.f[3:0];
endmodule
