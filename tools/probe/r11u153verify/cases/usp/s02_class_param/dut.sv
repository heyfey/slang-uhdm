// § unsignedScalarParamTsAtKeyword145
class c #(parameter bit unsigned P = 1'b1);
  bit x = P;
endclass
module top(output bit o);
  c #(1'b0) h;
  assign o = 1'b1;
endmodule
