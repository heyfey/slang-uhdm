// r11u92 n3 -- the INTERFACE twin of the non-ANSI port strength declaration.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire (strong1, weak0) [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
