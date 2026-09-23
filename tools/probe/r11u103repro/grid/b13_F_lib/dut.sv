// LAW B road F x library: the leaf lives in a -v library, reached only from a non-taken generate body
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
