// r11u93 pb5 -- an INPUT non-ANSI interface port.
interface ifc (i, p);
  input [31:0] i;
  output [31:0] p;
  wire [31:0] i;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.i(o), .p(q));
endmodule
