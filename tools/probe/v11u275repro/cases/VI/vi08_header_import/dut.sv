// § importNetTsDimEnd275 — an interface importing in its header
package p;
  logic [1:0][7:0] v;
endpackage
interface ifc import p::*; ();
  logic [15:0] y;
  assign y = v;
endinterface
module dut (output logic [15:0] o);
  ifc u ();
  assign o = u.y;
endmodule
