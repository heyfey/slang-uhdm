// § portViewNdaNetCellParent293
// CONTROL: a variable with an initializer.
interface ifc ();
  logic [7:0] w = 8'd5;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
