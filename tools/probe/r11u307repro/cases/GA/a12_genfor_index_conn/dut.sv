// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic [1:0][1:0] a, output logic [1:0][1:0] y);
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u_l [1:0] (.i(a[k]), .o(y[k]));
  end
endmodule
