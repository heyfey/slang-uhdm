// LAW B road F: an instance ARRAY of the ported leaf
module leaf (output logic l); assign l = 1'b0; endmodule
module orphan ();
  wire [1:0] r;
  leaf u_l [1:0] (.l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
