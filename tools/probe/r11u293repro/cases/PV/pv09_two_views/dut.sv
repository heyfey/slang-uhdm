// § portViewNdaNetCellParent293
// Two port views of two instances.
interface ifc ();
  wire [7:0] w = 8'd5;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o, output logic [7:0] o2);
  ifc u_a ();
  ifc u_b ();
  sub u_s (.p(u_a), .o(o));
  sub u_t (.p(u_b), .o(o2));
endmodule
