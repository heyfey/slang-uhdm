// § genCaConstRhsWhole433
interface ifc #(parameter W = 2);
  logic [7:0] y;
  logic [4:0] x;
  if (W > 1) begin: g
    assign y = W + 1;
  end
endinterface
module top;
  ifc #(.W(3)) i0();
endmodule
