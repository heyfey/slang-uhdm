// LAW A x LAW B: the dropped file-scope innermod AND a portless nested one that instantiates a ported leaf
module leaf (output logic l); assign l = 1'b0; endmodule
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod ();
    wire r;
    leaf u_l (.l(r));
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  innermod u_f ();
  assign o = 32'd0;
endmodule
