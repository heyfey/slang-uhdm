// § genCaLhsEnumConstClone158
module dut(input logic [7:0] a, output logic [7:0] o);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  for (genvar i = 0; i < 1; i++) begin : g
    wire [3:0][7:0] w;
    assign w[B] = a;
    assign o = w[B];
  end
endmodule
