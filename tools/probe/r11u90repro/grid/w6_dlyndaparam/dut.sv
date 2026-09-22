// r11u90 w6 -- LAW B on a NET DECLARATION's delay (`wire #D w = ...;`).
interface ifc ();
  parameter int D = 4;
  wire [31:0] w_d = 32'd10;
  wire #D [31:0] w_dd = 32'd11;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_d ^ u_if.w_dd;
endmodule
