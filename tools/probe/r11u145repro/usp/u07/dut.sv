// § unsignedScalarParamTsAtKeyword145
module sub #(parameter logic unsigned P = 1'b0) (output logic o);
  assign o = P;
endmodule
module top(output logic o);
  sub #(.P(1'b1)) u(.o(o));
endmodule
