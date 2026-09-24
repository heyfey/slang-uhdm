// nested module DECLARED and EXPLICITLY INSTANTIATED in the outer
module sub ();
  module innermod ();
    wire [31:0] r = 32'd2;
  endmodule
  innermod u_i ();
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
