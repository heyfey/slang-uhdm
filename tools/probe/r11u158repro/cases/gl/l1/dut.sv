// § genCaLhsEnumConstClone158
package p; typedef enum logic [2:0] {A=3'd0, B, C, D} e_t; endpackage
module dut(input logic [3:0][7:0] a, output logic [3:0][7:0] o);
  import p::*;
  for (genvar i = 0; i < 1; i++) begin : g
    assign o[C:B] = a[C:B];
  end
endmodule
