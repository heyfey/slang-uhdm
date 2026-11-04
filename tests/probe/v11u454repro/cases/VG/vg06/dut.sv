// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(interface a, interface b);
  assign a.v = b.x[0];
endmodule
module top;
  bus_if i1(); gp_if j1(); bus_if i2(); gp_if j2();
  m u1(.a(i1), .b(j1));
  m u2(.a(j2), .b(i2));
endmodule
