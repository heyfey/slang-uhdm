// § defGenOrderedConnPorts307
interface ifc; logic w; endinterface
module leaf (ifc p); assign p.w = 1'b1; endmodule
module outer (output logic y);
  ifc u_if ();
  if (1) begin : g
    leaf u_l (u_if);
  end
  assign y = u_if.w;
endmodule
module dut (output logic y);
  outer u1 (.y(y));
endmodule
