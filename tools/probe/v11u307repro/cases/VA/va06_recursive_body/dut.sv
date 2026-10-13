// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module mid (input logic [1:0] i, output logic [1:0] o);
  if (1) begin : h
    leaf u_x [1:0] (.i(i), .o(o));
  end
endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  if (1) begin : g
    mid u_m [1:0] (.i(a), .o(y));
  end
endmodule
