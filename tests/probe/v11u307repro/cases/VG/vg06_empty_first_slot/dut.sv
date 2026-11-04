// § defGenOrderedConnPorts307
module leaf (input logic i, input logic j, output logic o); assign o = j; endmodule
module outer (input logic a, output logic y);
  if (1) begin : g
    leaf u_l (, a, y);
  end
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
