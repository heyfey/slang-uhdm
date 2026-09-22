// v11u90 vx18 -- the INTERFACE twin of vx2: the dropped name is read by an
// assign inside the interface's OWN body.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  logic [31:0] c;
  assign c = w_plain ^ w_str;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
