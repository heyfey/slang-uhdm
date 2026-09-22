// r11u90 u3 -- LAW A in a module GENERATE scope.
module sub (output logic [31:0] o);
  if (1) begin : g
    wire [31:0] w_plain = 32'd11;
    wire (strong1, weak0) [31:0] w_str = 32'd12;
  end
  assign o = g.w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
