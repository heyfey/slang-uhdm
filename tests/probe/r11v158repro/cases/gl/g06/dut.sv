// § genCaLhsEnumConstClone158
package p; typedef enum int {A = 0, B = 4, C = 8} e_t; endpackage
module dut(input logic [15:0] a, output logic [15:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    assign o[p::C +: 4] = a[p::B +: 4];
    assign o[p::B] = a[p::A];
  end
endmodule
