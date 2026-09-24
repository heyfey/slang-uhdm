package mask_pkg;
  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  localparam s_t CFG = '{f: 8'h3C, g: 8'hC3};
endpackage
module top (input logic s, input logic [2:0] k, output logic [7:0] o);
  assign o = mask_pkg::CFG.f;
endmodule
