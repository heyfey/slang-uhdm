// § unsignedScalarParamTsAtKeyword145
module sub #(parameter logic unsigned EN = 1'b1) (output logic o);
  assign o = EN;
endmodule
module top(output logic o);
  sub #(.EN(1'b0)) u(.o(o));
endmodule
