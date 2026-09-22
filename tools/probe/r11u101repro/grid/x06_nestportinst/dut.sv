// CONTROL: a ported nested module EXPLICITLY instantiated (a real instance exists)
module sub ();
  module innermod (output logic [31:0] r);
    assign r = 32'd2;
  endmodule
  wire [31:0] q;
  innermod u_i (.r(q));
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
