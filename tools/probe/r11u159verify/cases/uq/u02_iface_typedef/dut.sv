// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
interface bus_if;
  typedef struct packed { fp::cf_t [1:0] at; logic z; } t_t;
  t_t v;
endinterface
module top(output logic [4:0] o);
  bus_if b();
  assign b.v = '0;
  assign o = b.v;
endmodule
