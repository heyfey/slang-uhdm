// § ifaceArrPortSizeDimAtExpr183 (a parameter size, two array ports, a generic interface array port)
interface bus_if; logic v; modport mp(input v); endinterface
module sink #(parameter int N = 2)(bus_if.mp p[N], bus_if q[N+1], interface r[2]);
endmodule
module top;
  bus_if b[2]();
  bus_if c[3]();
  bus_if d[2]();
  sink #(.N(2)) s(.p(b), .q(c), .r(d));
endmodule
