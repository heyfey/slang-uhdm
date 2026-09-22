// v11u93 v10 -- a BODY net BETWEEN the two port declarations.
interface ifc (o, p);
  output [31:0] o;
  wire [31:0] mid = 32'd14;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
