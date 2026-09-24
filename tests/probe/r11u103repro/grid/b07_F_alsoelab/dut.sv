// CONTROL road F: leaf is ALSO instantiated in the elaborated tree (the walk fills it)
module leaf (output logic l); assign l = 1'b0; endmodule
module orphan ();
  wire r;
  leaf u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  wire z;
  leaf u_z (.l(z));
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
