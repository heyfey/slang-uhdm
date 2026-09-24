// LAW B road F: leaf with an UNPACKED array port
module leaf (output logic [1:0] l [2]); assign l[0] = '0; assign l[1] = '1; endmodule
module orphan ();
  logic [1:0] r [2];
  leaf u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
