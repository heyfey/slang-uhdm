// r11u90 w9 -- LAW B: a min:typ:max delay over parameter names.
interface ifc ();
  parameter int D = 4;
  parameter int E = 6;
  parameter int F = 8;
  logic [31:0] c;
  assign #(D:E:F) c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
