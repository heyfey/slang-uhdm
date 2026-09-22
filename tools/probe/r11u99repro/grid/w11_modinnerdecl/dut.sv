// NESTED MODULE DECLARATION, classes in both  [= v29]
module sub ();
  class Zouter; int z; endclass
  module innermod ();
    class Zinner; int z; endclass
    class Ainner; int a; endclass
  endmodule
  class Aouter; int a; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
