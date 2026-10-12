// § wireScopedTdEndAtType305
package pk;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endpackage
interface ifc;
  wire pk::sa_t sn;
endinterface
module top (output logic [2:0] o);
  ifc u ();
  assign o = u.sn.a;
endmodule
