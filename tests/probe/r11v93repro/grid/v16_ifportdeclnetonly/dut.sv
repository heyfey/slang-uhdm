// v11u93 v16 -- the PORT DECLARATION carries the net keyword, no body re-decl.
interface ifc (o, p);
  output wire [31:0] o;
  output wire [31:0] p;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
