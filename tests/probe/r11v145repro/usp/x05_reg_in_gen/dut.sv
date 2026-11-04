// § unsignedScalarParamTsAtKeyword145
module top(output reg o);
  parameter reg unsigned R = 1'b1;
  if (R) begin : g
    always_comb o = R;
  end
endmodule
