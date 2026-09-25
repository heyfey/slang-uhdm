// § genCaLhsEnumConstClone158
module dut(input logic [15:0] a, output logic [15:0] o);
  typedef enum int {A = 0, B = 4, C = 8} e_t;
  for (genvar i = 0; i < 1; i++) begin : g
    assign o[B +: 4] = a[C +: 4];
  end
endmodule
