// § defGenOrderedConnPorts307
module leaf #(parameter int W = 1) (output logic o, input logic i); assign o = i; endmodule
module outer (input logic a, output logic y);
  if (1) begin : g
    leaf #(.W(2)) u_l (y, a);
  end
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
