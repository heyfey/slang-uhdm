// a nested module whose ONLY content is classes, outer has none
module sub ();
  module innermod ();
    class Zinner; int z; endclass
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
