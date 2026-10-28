// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(interface.mp a, interface b);
  assign a.v = b.x[0];
endmodule
module top;
  bus_if i(); gp_if j();
  m u(.a(i), .b(j));
endmodule
