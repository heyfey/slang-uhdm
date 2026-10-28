// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
module m(interface a, interface.mp b, interface c);
  assign b.v = a.x[0] ^ c.x[1];
endmodule
module top;
  bus_if i(); gp_if j(); gp_if k();
  m u(.a(i), .b(j), .c(k));
endmodule
