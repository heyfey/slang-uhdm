// r11u90 u11 -- LAW A: the dropped net named by a MODPORT.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  modport mp (input w_plain, input w_str);
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_plain;
endmodule
