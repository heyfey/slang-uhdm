// § rawEndLineModel295
`define INIT 8'h7
package p;
  logic [7:0] v = `INIT;
endpackage
interface ifc;
  import p::*;
  logic [7:0] w;
  assign w = v;
endinterface
module top(output logic [7:0] o);
  ifc i();
  assign o = i.w;
endmodule
