// LAW B road F: the unelaborated body instantiates an INTERFACE (interface def excluded) and a ported leaf
interface bus; logic v; endinterface
module leaf (output logic l); assign l = 1'b0; endmodule
module orphan ();
  bus bb ();
  wire r;
  leaf u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
