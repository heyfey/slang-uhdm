// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic [2:0] a, output logic [2:0] y);
  if (1) begin : g
    leaf u_s (.i(a[2]), .o(y[2]));
    leaf u_l [1:0] (.i(a[1:0]), .o(y[1:0]));
  end
endmodule
