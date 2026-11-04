// § genScopeModArrayElems307
module leaf (input logic [1:0] i, output logic o); assign o = i[1] & ~i[0]; endmodule
module dut (input logic [7:0] a, output logic [3:0] y);
  if (1) begin : g
    leaf u_l [3:0] (.i(a), .o(y));
  end
endmodule
