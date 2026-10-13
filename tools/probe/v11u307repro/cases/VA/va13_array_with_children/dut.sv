// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module mid (input logic i, output logic o);
  logic t;
  leaf u_a (.i(i), .o(t));
  leaf u_b (.i(t), .o(o));
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  if (1) begin : g
    mid u_m [1:0] (.i(a), .o(y));
  end
endmodule
