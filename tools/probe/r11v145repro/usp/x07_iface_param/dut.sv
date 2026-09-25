// § unsignedScalarParamTsAtKeyword145
interface ifc #(parameter logic unsigned E = 1'b1);
  logic d;
  assign d = E;
endinterface
module top(output logic o);
  ifc #(.E(1'b0)) u();
  assign o = u.d;
endmodule
