// § genCaAddParamIntCt435
interface ifc #(parameter W = 4'd2);
  logic [7:0] y;
  if (1) begin: g
    assign y = W + 1;
  end
endinterface
module top;
  ifc u();
endmodule
