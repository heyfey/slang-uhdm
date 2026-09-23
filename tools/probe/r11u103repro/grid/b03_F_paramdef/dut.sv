// LAW B road F: parameterized leaf (defaulted), overridden
module leaf #(parameter int W = 3) (output logic [W-1:0] l); assign l = '0; endmodule
module orphan ();
  logic [5:0] r;
  leaf #(.W(6)) u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
