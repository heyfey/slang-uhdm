// r11u92 n4 -- THE INTERFACE CONTROL: non-ANSI ports, both body
// re-declarations PLAIN.  The interface road's own port-net shape, measured
// WITHOUT a strength anywhere.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
