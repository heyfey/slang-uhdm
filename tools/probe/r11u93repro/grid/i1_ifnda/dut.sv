// r11u92 i1 -- THE INTERFACE CONTROL: the same nda in an interface home.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = 32'd0;
endmodule
