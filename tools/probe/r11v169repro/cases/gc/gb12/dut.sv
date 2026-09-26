// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], output logic [31:0] o [2]);
  parameter int P = 6;
  typedef struct packed { logic [7:0] f; logic [7:0] h; } s_t;
  s_t s;
  assign s = 16'h1234;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] ^ s.f[P % 8];
  end
endmodule
