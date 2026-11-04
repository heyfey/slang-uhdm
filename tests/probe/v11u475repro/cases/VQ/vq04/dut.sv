// § pkgQualCaReadValueForm475
// a large 32-bit decimal and an interface reader
package p;
  parameter logic [31:0] P = 32'd4294967295;
endpackage
interface ifc;
  logic [31:0] y;
  assign y = p::P;
endinterface
module top(output logic [31:0] y);
  ifc i();
  assign y = p::P;
endmodule
