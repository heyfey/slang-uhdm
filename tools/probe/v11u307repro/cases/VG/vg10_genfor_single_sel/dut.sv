// § defGenOrderedConnPorts307
module leaf (input logic i); endmodule
module outer (input logic [1:0] a);
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u_l (a[k]);
  end
endmodule
module dut (input logic [1:0] a);
  outer u1 (.a(a));
endmodule
