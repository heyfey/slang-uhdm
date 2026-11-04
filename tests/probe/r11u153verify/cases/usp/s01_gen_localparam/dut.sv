// § unsignedScalarParamTsAtKeyword145
module top(output logic o);
  if (1) begin : g
    localparam logic unsigned Q = 1'b0;
    assign o = Q;
  end
endmodule
