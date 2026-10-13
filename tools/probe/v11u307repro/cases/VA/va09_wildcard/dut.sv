// § genScopeModArrayElems307
module leaf (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic i, output logic [1:0] o2);
  if (1) begin : g
    logic o;
    leaf u_l [1:0] (.*);
    assign o2 = {2{o}};
  end
endmodule
