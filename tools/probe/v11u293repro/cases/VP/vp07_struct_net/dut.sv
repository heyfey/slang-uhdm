// § portViewNdaNetCellParent293
// A struct-typed net with an initializer.
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
endpackage
interface ifc ();
  wire pk::st_t w = '{a: 4'd1, b: 4'd2};
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [3:0] o);
  assign o = p.w.a;
endmodule
module top (output logic [3:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
