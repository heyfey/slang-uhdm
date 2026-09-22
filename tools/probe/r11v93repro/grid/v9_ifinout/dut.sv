// v11u93 v9 -- an INOUT non-ANSI interface port.
interface ifc (o, p);
  inout [31:0] o;
  input [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
