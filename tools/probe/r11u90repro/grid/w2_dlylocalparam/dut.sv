// r11u90 w2 -- LAW B: a LOCALPARAM delay name.
interface ifc ();
  localparam int L = 5;
  logic [31:0] c;
  assign #L c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
