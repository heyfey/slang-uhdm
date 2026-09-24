// v11u93 v12 -- TWO instances of the SAME non-ANSI interface.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q, r, t;
  ifc u_if (.o(o), .p(q));
  ifc u_if2 (.o(r), .p(t));
endmodule
