// r11u90 u4 -- LAW A in an interface GENERATE scope.
interface ifc ();
  if (1) begin : g
    wire [31:0] w_plain = 32'd11;
    wire (strong1, weak0) [31:0] w_str = 32'd12;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.g.w_plain;
endmodule
