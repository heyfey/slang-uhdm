// § portViewNdaNetCellParent293
// CONTROL: a variable initializer (no cell).
interface ifc ();
  logic [7:0] v = 8'd5;
  modport mp (input v);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.v;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
