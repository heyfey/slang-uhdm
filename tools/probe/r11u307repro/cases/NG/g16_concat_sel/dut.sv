// § defGenOrderedConnPorts307
module leaf (input logic [1:0] i, output logic o); assign o = ^i; endmodule
module outer (input logic [3:0] a, output logic y);
  if (1) begin : g
    leaf u_l ({a[0], a[3]} , y);
  end
endmodule
module dut (input logic [3:0] a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
