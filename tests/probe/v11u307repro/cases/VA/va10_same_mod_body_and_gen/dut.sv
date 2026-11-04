// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  leaf u_b [1:0] (.i(a[1:0]), .o(y[1:0]));
  if (1) begin : g
    leaf u_l [1:0] (.i(a[3:2]), .o(y[3:2]));
  end
endmodule
