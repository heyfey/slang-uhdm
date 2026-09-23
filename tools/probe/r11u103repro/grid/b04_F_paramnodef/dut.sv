// LAW B road F: leaf parameter has NO default, overridden
module leaf #(parameter int K) (output logic [K-1:0] l); assign l = '1; endmodule
module orphan ();
  logic [3:0] r;
  leaf #(.K(4)) u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
