// LAW A: a NON-ANSI port list
module sub ();
  module innermod (a, y);
    input a;
    output y;
    wire a;
    wire y;
    assign y = ~a;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
