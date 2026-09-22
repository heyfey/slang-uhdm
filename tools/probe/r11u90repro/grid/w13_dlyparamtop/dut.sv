// r11u90 w13 -- LAW B in the TOP module (def view only reachable home).
module dut (output logic [31:0] o);
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
  assign o = c;
endmodule
