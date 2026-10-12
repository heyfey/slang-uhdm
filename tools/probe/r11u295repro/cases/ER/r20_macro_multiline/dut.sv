// § rawEndLineModel295
`define DECL2(n) \
  logic [7:0] n = 8'h2;
module dut (output logic [7:0] o);
  `DECL2(mm)
  assign o = mm;
endmodule
