// LAW B road NP: minted PORTED nested -> mid -> leaf
module leaf (output logic l); assign l = 1'b0; endmodule
module mid (output logic m); leaf u_l (.l(m)); endmodule
module sub ();
  module innermod (output logic r);
    mid u_m (.m(r));
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
