// r11u90 w3 -- LAW B: the delay is an EXPRESSION over a parameter, not a name.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c;
  assign #(D+1) c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
