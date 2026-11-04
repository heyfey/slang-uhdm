// § defGenOrderedConnPorts307
interface ifc; logic w; endinterface
module leaf (ifc p); assign p.w = 1'b1; endmodule
module outer (ifc q);
  if (1) begin : g
    leaf u_l (q);
  end
endmodule
module dut (output logic y);
  ifc u_if ();
  outer u1 (.q(u_if));
  assign y = u_if.w;
endmodule
