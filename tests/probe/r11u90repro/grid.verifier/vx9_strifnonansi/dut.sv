// v11u90 vx9 -- the u12 boundary inside an INTERFACE: a non-ANSI port net
// that ALSO carries a strength declaration.
interface ifc (o);
  output [31:0] o;
  wire (strong1, weak0) [31:0] o = 32'd12;
  wire [31:0] w_plain = 32'd11;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(q));
  assign o = q ^ u_if.w_plain;
endmodule
