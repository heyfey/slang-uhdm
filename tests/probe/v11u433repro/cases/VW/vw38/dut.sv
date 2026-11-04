// § genCaConstRhsWhole433
interface ifc #(parameter W = 2);
  logic [7:0] y;
  if (W <= 4) begin: g
    assign y = W + 1;
  end
endinterface
module top; ifc #(3) i(); endmodule
