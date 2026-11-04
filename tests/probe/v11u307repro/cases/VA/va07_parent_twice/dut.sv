// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module mid (input logic [1:0] i, output logic [1:0] o);
  if (1) begin : h
    leaf u_x [1:0] (.i(i), .o(o));
  end
endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  mid u_m0 (.i(a[1:0]), .o(y[1:0]));
  mid u_m1 (.i(a[3:2]), .o(y[3:2]));
endmodule
