// LAW B road F (unreferenced under -top dut): orphan is instantiated nowhere
module leaf (output logic l); assign l = 1'b0; endmodule
module orphan ();
  wire r;
  leaf u_l (.l(r));
endmodule
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
