// § genCaLhsEnumConstClone158
package p; typedef enum logic [2:0] {A, B, C, D} e_t; endpackage
module dut(input logic [1:0][3:0][7:0] a, output logic [1:0][3:0][7:0] o);
  import p::*;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i][C:A] = a[i][D:B];
    assign o[i][D] = a[i][A];
  end
endmodule
