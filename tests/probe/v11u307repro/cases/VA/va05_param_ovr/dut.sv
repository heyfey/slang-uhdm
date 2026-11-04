// § genScopeModArrayElems307
module leaf #(parameter logic V = 0) (input logic i, output logic o); assign o = i ^ V; endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  if (1) begin : g
    leaf #(.V(1)) u_l [1:0] (.i(a), .o(y));
  end
endmodule
