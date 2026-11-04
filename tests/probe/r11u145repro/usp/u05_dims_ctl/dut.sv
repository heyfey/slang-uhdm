// § unsignedScalarParamTsAtKeyword145 (control: a packed dimension keeps the whole span)
module top(output bit [3:0] o);
  parameter bit unsigned [3:0] P = 4'h3;
  assign o = P;
endmodule
