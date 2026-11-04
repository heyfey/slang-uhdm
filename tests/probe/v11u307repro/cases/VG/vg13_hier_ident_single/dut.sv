// § defGenOrderedConnPorts307
module leaf (input logic [1:0] i); endmodule
module outer (input logic [1:0] a);
  logic [1:0] w;
  assign w = a;
  if (1) begin : g
    leaf u_l (w);
    leaf u_m (w[1:0]);
  end
endmodule
module dut (input logic [1:0] a);
  outer u1 (.a(a));
endmodule
