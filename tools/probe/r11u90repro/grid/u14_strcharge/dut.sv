// r11u90 u14 -- the CHARGE strength (`trireg (small)`), a different parse node.
interface ifc ();
  trireg (small) [31:0] t_small;
  trireg [31:0] t_plain;
  wire [31:0] w_p = 32'd1;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_p;
endmodule
