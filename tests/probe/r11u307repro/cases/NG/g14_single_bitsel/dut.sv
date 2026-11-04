// § defGenOrderedConnPorts307
module inner (input logic i, output logic o); assign o = ~i; endmodule
module leaf (input logic i); endmodule
module outer (input logic [3:0] a);
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u_l (a[k]);
  end
endmodule
module dut (input logic [3:0] a);
  outer u1 (.a(a));
endmodule
