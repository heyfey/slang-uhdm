// § portViewNdaNetCellParent293
// CONTROL: a non-ANSI header port (the port declaration signal comes first).
interface ifc (o);
  output [31:0] o;
  wire [31:0] o = 32'd12;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
endmodule
module top (output logic [31:0] o);
  ifc u_if (.o(o));
  sub u_s (.m(u_if.mp));
endmodule
