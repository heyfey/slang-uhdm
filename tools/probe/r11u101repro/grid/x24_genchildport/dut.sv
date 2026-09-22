// CONTROL (file-scope def-only road): a module reached only from a NON-TAKEN generate branch instantiates a PORTED leaf
module leaf (output logic l); assign l = 1'b0; endmodule
module orphan ();
  wire r;
  leaf u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
