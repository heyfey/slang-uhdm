// v11u90 vy15 -- the module carrying the delay-ref cell is NEVER
// instantiated: only the DEFINITION view exists.
module unused_sub (output logic [31:0] o);
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  assign o = 32'd1;
endmodule
