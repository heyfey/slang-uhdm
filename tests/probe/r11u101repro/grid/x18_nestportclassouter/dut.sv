// LAW A x pass-98 B3: the outer holds a class, the ported nested one holds a class
module sub ();
  class Aout; int a; endclass
  module innermod (output logic [31:0] r);
    class Binner; int b; endclass
    assign r = 32'd2;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
