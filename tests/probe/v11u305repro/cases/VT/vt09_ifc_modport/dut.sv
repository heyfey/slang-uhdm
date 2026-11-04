// § scopedSimpleTdMemberBindsListing305
package pk; typedef logic [2:0] w_t; endpackage
interface ifc;
  typedef struct packed { pk::w_t a; logic b; } s_t;
  s_t x;
  modport mp (input x);
endinterface
module c (ifc.mp p, output logic [2:0] o); assign o = p.x.a; endmodule
module dut (output logic [2:0] o);
  ifc u ();
  c cc (u.mp, o);
endmodule
