// § genCaLhsEnumConstClone158
package pk; typedef enum int { E_LO = 1, E_HI = 3 } e_t; endpackage
module top (input logic [3:0] a, output logic [7:0] o);
  import pk::*;
  for (genvar i = 0; i < 1; i++) begin : GI
    assign o[E_HI:E_LO] = a[2:0];
  end
endmodule
