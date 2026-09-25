// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
interface ifc import pk::*;;
  s_t [2:0] v;
endinterface
module top (output int x);
  ifc i();
  assign x = int'(i.v);
endmodule
