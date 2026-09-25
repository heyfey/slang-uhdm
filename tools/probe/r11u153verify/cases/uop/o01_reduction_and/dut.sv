// § unaryOperandParamOwnerName145
module dut #(parameter logic [3:0] M = 4'hF) ();
  logic o [2];
  if (1) begin : g
    localparam int c = 0;
    assign o[c] = &M;
  end
endmodule
