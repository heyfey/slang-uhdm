// § impElabArithWholeSpan145
package pk;
  parameter int unsigned S = 32;
  parameter int unsigned BY = S/8;
endpackage
interface ifc;
  import pk::*;
  logic [BY-1:0] d;
endinterface
module top(output logic o);
  ifc i();
  assign o = i.d[0];
endmodule
