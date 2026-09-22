// r11u93 pb7 -- three non-ANSI interface ports with a plain body net between.
interface ifc (o, p, r);
  output [31:0] o;
  output [31:0] p;
  output [31:0] r;
  wire [31:0] o = 32'd12;
  wire [31:0] mid = 32'd14;
  wire [31:0] p = 32'd13;
  wire [31:0] r = 32'd15;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q, t;
  ifc u_if (.o(o), .p(q), .r(t));
endmodule
