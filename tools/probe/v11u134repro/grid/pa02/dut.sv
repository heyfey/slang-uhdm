// § typedefParentLastWriter134
package p;
  typedef union packed { logic [7:0] b; struct packed { logic [3:0] hi, lo; } n; } u_t;
endpackage
interface bus_if;
  import p::*;
  u_t d;
endinterface
module sink(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  u_t q;
  always_comb q.b = i;
  assign o = q.n.hi;
endmodule
module top(input logic [7:0] i, output logic [3:0] o);
  bus_if b();
  sink s(.i(i), .o(o));
endmodule
