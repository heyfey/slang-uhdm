// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic [5:0] a, output logic [5:0] y);
  if (1) begin : g
    leaf u_l [1:0][2:0] (.i(a), .o(y));
  end
endmodule
