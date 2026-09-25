// § genCaLhsEnumConstClone158
package p; typedef enum logic [1:0] {A, B, C, D} e_t; endpackage
module dut(input logic [7:0] a, output logic [3:0][7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 1) begin : h
      assign o[p::D] = a;
    end
  end
endmodule
