// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic a, output logic y);
  if (1) begin : g
    leaf u_l [0:0] (.i(a), .o(y));
  end
endmodule
