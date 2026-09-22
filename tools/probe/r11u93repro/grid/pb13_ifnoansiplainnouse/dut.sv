// r11u93 pb13 -- non-ANSI interface ports, NO body declarations at all.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
