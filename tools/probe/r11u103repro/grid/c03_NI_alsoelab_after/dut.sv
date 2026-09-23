// CONTROL road NI: leaf ALSO instantiated in dut AFTER sub (representative under the implicit body, the walk fills from dut)
module leaf (output logic l); assign l = 1'b0; endmodule
module sub ();
  module innermod ();
    wire r;
    leaf u_l (.l(r));
  endmodule
endmodule
module dut (output logic [31:0] o);
  wire z;
  sub u_s ();
  leaf u_z (.l(z));
  assign o = 32'd0;
endmodule
