// § defGenOrderedConnPorts307
module inner (input logic [1:0] i, output logic o); assign o = ^i; endmodule
module outer (input logic a, output logic y);
  if (1) begin : g
    inner u_in ({a, 1'b1}, y);
  end
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
