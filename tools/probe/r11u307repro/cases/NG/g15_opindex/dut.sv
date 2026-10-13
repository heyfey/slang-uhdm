// § defGenOrderedConnPorts307
module leaf (input logic i); endmodule
module outer (input logic [3:0] a);
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u_l (a[2*k+1]);
  end
endmodule
module dut (input logic [3:0] a);
  outer u1 (.a(a));
endmodule
