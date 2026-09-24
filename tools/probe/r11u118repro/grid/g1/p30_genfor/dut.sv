package mask_pkg;
  localparam logic [63:0] MASK = 64'hDEADBEEF_12345678;
  localparam logic [1:0][7:0] ARR = 16'hA55A;
  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  localparam s_t CFG = '{f: 8'h3C, g: 8'hC3};
endpackage
module top (input logic s, output logic [31:0] o);
  for (genvar i = 0; i < 4; i++) begin : g
    assign o[i*8 +: 8] = s ? mask_pkg::MASK[i*8 +: 8] : '0;
  end
endmodule
