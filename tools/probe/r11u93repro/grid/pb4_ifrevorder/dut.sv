// r11u93 pb4 -- the interface body re-declarations in the REVERSE order of
// the port declarations.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] p = 32'd13;
  wire [31:0] o = 32'd12;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
