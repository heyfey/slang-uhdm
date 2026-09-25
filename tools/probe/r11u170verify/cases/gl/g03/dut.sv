// § genCaLhsEnumConstClone158
package pk; typedef enum logic [2:0] { K0 = 3'd0, K4 = 3'd4 } k_t; endpackage
module top #(parameter int M = 2) (input logic [3:0] a, output logic [7:0] o);
  import pk::*;
  case (M)
    2: begin : C assign o[K4 +: 4] = a; end
    default: begin : C assign o[K0 +: 4] = a; end
  endcase
endmodule
