// r11u93 pb17 -- ONE port declaration naming BOTH ports.
interface ifc (o, p);
  output [31:0] o, p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
