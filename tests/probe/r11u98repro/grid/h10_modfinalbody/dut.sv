// r11u98 h10 -- CONTROL for h4: the same final in the MODULE BODY, no generate.
module sub ();
  wire [31:0] w_plain = 32'd11;
  final begin
    $display("bye");
  end
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
