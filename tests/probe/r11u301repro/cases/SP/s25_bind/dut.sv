// § caSelLhsParamReuseAnyEnc301
module chk #(parameter int Z = 5)();
  logic [7:0] arr[2];
  assign arr[0] = Z;
endmodule
module dut;
  logic x;
endmodule
bind dut chk #(.Z(4)) u_c();
