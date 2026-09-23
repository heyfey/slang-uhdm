// LAW B road NI: leaf with two ports, positional connection
module leaf (input logic a, output logic b); assign b = a; endmodule
module sub ();
  module innermod ();
    wire x, y;
    leaf u_l (x, y);
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
