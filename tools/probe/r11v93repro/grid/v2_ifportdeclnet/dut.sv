// v11u93 v2 -- the PORT DECLARATION itself carries the net keyword.
interface ifc (o, p);
  output wire [31:0] o;
  output wire [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
