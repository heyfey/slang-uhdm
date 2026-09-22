// r11u90 u5 -- LAW A: the strength net is READ.  Does the reference mint it?
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_plain ^ u_if.w_str;
endmodule
