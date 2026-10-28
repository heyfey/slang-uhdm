// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(bus_if a, interface b, interface c);
  assign a.v = b.x[0] | c.x[0];
endmodule
module top;
  bus_if i(); gp_if j(); gp_if k();
  m u(.a(i), .b(j), .c(k));
endmodule
