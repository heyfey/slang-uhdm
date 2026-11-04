// § caSelLhsParamReuseAnyEnc301
module m #(parameter int Z = 5)();
  logic [7:0] arr[2];
  if (1) begin : g
    assign arr[0] = Z;
  end
endmodule
module dut;
  m u_a();
endmodule
