// § unaryOperandParamOwnerName145 (control: BasicOh oh_dsync's shape, a plain-reference lhs)
module sub #(parameter DELAY = 0) (input logic [1:0] s, output logic o);
  if (1) begin
    assign o = (DELAY & s[1]) | (~DELAY & s[0]);
  end
endmodule
module dut(input logic [1:0] s, output logic o);
  sub u(.s(s), .o(o));
endmodule
