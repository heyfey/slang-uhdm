// § portViewNdaNetCellParent293
// An initializer reading a package parameter.
package pk;
  localparam int W = 7;
endpackage
interface ifc ();
  wire [7:0] w = pk::W;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
