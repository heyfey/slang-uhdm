// § genCaConstRhsWhole433
interface ifc #(parameter W = 2);
  logic [7:0] y;
  if (W > 1) begin: g
    logic [3:0] z;
    assign y = $bits(z);
  end
endinterface
module top;
  ifc #(.W(3)) i0();
endmodule
