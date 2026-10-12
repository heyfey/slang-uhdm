// § portViewNdaNetCellParent293
// Two modports list the same net.
interface ifc ();
  wire [7:0] w = 8'd1;
  logic [7:0] v;
  modport ma (input w, output v);
  modport mb (input w);
endinterface
module sa (ifc.ma p);
  assign p.v = p.w;
endmodule
module sb (ifc.mb p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sa u_a (.p(u_if));
  sb u_b (.p(u_if), .o(o));
endmodule
