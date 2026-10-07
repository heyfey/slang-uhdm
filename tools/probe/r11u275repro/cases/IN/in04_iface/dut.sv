// § importNetTsDimEnd275 — the interface road
package p;
  logic [7:0] a [0:1];
  logic [3:0][1:0] k;
endpackage
interface ifc;
  import p::*;
  logic [7:0] own;
endinterface
module dut (output logic [7:0] o);
  ifc u ();
  assign o = u.own;
endmodule
