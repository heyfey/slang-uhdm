// r11u88 z2b -- LAW B x a PARAMETER-REF delay.  `assign #D c = ...;` alone is
// written (writeCont_assign binds the ref); with a strength in front of it the
// producer declines the cell exactly as z1 does.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c_dref;
  logic [31:0] c_dboth;
  assign #D c_dref = 32'd10;
  assign (weak1, strong0) #D c_dboth = 32'd11;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c_dref ^ u_if.c_dboth;
endmodule
