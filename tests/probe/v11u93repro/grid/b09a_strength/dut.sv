module sub ();
  module innermod (input logic a, input logic b, output wire y, output wire z);
    assign (strong0, weak1) #1 y = a & b;
    assign #(2,3) z = a | b;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
