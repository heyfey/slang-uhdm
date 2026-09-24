// r11u93 pb12 -- a STRENGTH net declaration in an interface that is NOT a port.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
  wire (strong1, weak0) [31:0] loose = 32'd14;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
