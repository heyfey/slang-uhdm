// LAW B road F: orphan -> mid -> leaf (depth 2 under the unelaborated root)
module leaf (output logic l); assign l = 1'b0; endmodule
module mid (output logic m); leaf u_l (.l(m)); endmodule
module orphan ();
  wire r;
  mid u_m (.m(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
