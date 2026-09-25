// § genCaLhsEnumConstClone158
module dut(input logic [3:0][7:0] a, output logic [3:0][7:0] o);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  if (1) begin : g
    for (genvar i = 0; i < 1; i++) begin : h
      assign o[B:A] = a[D:C];
    end
  end
endmodule
