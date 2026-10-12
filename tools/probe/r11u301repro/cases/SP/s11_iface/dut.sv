// § caSelLhsParamReuseAnyEnc301
interface ifc #(parameter int Z = 3);
  logic [7:0] arr[2];
  assign arr[0] = Z;
endinterface
module dut;
  ifc #(.Z(6)) u_i();
endmodule
