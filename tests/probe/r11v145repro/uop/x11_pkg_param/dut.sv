// § unaryOperandParamOwnerName145
package pk;
  parameter logic [7:0] M = 8'h0f;
endpackage
module dut(input logic [7:0] a [2], output logic [7:0] o [2]);
  import pk::*;
  if (1) begin : g
    assign o[0] = a[0] & ~M;
  end
endmodule
