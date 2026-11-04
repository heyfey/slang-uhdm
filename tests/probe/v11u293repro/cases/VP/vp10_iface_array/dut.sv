// § portViewNdaNetCellParent293
// An interface instance array, each element on a port view.
interface ifc ();
  wire [7:0] w = 8'd7;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o, output logic [7:0] o2);
  ifc u_if [2] ();
  sub u_a (.p(u_if[0]), .o(o));
  sub u_b (.p(u_if[1]), .o(o2));
endmodule
