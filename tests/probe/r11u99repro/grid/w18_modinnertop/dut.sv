// nested module declaration inside a module that is itself the TOP
module dut (output logic [31:0] o);
  module innermod ();
    class Cin; int c; endclass
  endmodule
  class Cout; int c; endclass
  assign o = 32'd0;
endmodule
