// § unaryOperandParamOwnerName145
interface ifc #(parameter logic [7:0] M = 8'h0f);
  logic [7:0] a [2];
  logic [7:0] o [2];
  if (1) begin : g
    assign o[0] = a[0] & ~M;
  end
endinterface
module dut();
  ifc u();
endmodule
