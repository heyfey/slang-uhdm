// § pkgLeafPatLocByWriting152
package pk;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
interface bus_if import pk::*; (input s_t [1:0] d);
endinterface
module top(input logic [3:0] i);
  bus_if b(.d(i));
endmodule
