// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  if (1) begin : g
    if (1) begin : h
      leaf u_l [1:0] (.i(a), .o(y));
    end
  end
endmodule
