// r11u93 pb3 -- an interface non-ANSI port with NO body re-declaration.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
