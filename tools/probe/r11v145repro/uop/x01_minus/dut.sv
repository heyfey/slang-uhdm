// § unaryOperandParamOwnerName145
module dut #(parameter int M = 5) ();
  int a [2];
  int o [2];
  if (1) begin : g
    assign o[0] = a[0] + -M;
  end
endmodule
