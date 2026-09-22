// r11u93 pb19 -- a MODPORT-connected port view of a non-ANSI interface.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
  modport mp (output o, output p);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
  sub u_s (.m(u_if.mp));
  assign o = 32'd0;
endmodule
