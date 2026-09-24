package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  localparam logic [1:0][7:0] ARR = 16'hA55A;
  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  localparam s_t CFG = '{f: 8'h3C, g: 8'hC3};
endpackage
module top (input logic s, output logic [3:0] o);
  assign o = s ? mask_pkg::CFG.f[3:0] : '0;
endmodule
