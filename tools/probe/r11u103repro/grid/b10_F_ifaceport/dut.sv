// LAW B road F: leaf has an INTERFACE port (interface defs stay out of unrefDefs; the leaf is a module)
interface bus; logic v; endinterface
module leaf (bus b, output logic l); assign l = b.v; endmodule
module orphan ();
  bus bb ();
  wire r;
  leaf u_l (.b(bb), .l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
