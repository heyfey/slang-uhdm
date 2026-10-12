// § portViewNdaNetCellParent293
// The modport named at the connection.
interface ifc ();
  wire [7:0] w = 8'd8;
  modport mp (input w);
endinterface
module sub (ifc p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if.mp), .o(o));
endmodule
