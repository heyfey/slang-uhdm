// § unaryOperandParamOwnerName145 (control: a plain-reference lhs)
module dut #(parameter DELAY = 1) (input logic [1:0] s, output logic o);
  if (1) begin : g
    assign o = ~DELAY & s[0];
  end
endmodule
