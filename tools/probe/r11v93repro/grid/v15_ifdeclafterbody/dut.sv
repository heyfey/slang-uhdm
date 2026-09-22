// v11u93 v15 -- the PORT DECLARATION written AFTER the body re-declaration.
interface ifc (o, p);
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
  output [31:0] o;
  output [31:0] p;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
