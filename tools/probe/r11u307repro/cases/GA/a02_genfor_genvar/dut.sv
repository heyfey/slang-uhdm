// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u_l [1:0] (.i(a[2*k+1:2*k]), .o(y[2*k+1:2*k]));
  end
endmodule
