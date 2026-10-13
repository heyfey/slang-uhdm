// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module mid (input logic [1:0] a, output logic [1:0] y);
  for (genvar k = 0; k < 1; k++) begin : g
    leaf u_l [1:0] (.i(a), .o(y));
  end
endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  mid u_m0 (.a(a[1:0]), .y(y[1:0]));
  mid u_m1 (.a(a[3:2]), .y(y[3:2]));
endmodule
