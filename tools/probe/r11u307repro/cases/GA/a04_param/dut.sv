// § genScopeModArrayElems307
module leaf #(parameter int W = 1) (input logic [W-1:0] i, output logic [W-1:0] o); assign o = ~i; endmodule
module dut (input logic [3:0] a, output logic [3:0] y);
  if (1) begin : g
    leaf #(.W(2)) u_l [1:0] (.i(a), .o(y));
  end
endmodule
