module sub ();
  module innermod (input logic [3:0] a, output logic [3:0] y);
    wire [3:0] t = a ^ 4'h5;
    wire (weak0, weak1) [1:0] u = a[1:0];
    assign y = {t[3:2], u};
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
