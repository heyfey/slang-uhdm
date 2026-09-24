// v11u93 v17 -- an INOUT and an INPUT non-ANSI interface port.
interface ifc (o, p);
  inout [31:0] o;
  input [31:0] p;
  wire [31:0] o;
  wire [31:0] p;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  wire [31:0] w;
  ifc u_if (.o(w), .p(q));
  assign o = 32'd0;
endmodule
