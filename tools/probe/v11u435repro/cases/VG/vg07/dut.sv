// § genCaAddParamIntCt435
package p;
  parameter W = 4'd2;
endpackage
module top;
  logic [7:0] y;
  if (1) begin: g
    assign y = p::W + 1;
  end
endmodule
