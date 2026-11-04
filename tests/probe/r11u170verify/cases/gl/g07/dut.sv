// § genCaLhsEnumConstClone158
package pk; typedef enum int { E_LO = 1, E_HI = 3 } e_t; endpackage
module top (input logic [3:0] a [2][2], output logic [7:0] o [2][2]);
  import pk::*;
  for (genvar i = 0; i < 2; i++) begin : GI
    for (genvar j = 0; j < 2; j++) begin : GJ
      assign o[i][j][E_HI:E_LO] = a[i][j][2:0];
    end
  end
endmodule
