// § defGenOrderedConnPorts307
module inner (output logic o); assign o = 1'b1; endmodule
module outer (output logic y);
  if (1) begin : g
    inner u_in (y);
  end
endmodule
module dut (output logic y);
  outer u1 (.y(y));
endmodule
