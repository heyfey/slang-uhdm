// v11u93 v3 -- the PORT DECLARATION is a VARIABLE (output reg).
interface ifc (o, p);
  output reg [31:0] o;
  output [31:0] p;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
