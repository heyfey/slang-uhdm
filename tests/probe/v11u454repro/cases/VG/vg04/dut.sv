// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(interface a, interface b, input logic c, output logic d);
  assign d = c & a.x[0] & b.x[1];
endmodule
module top(input logic c, output logic d);
  bus_if i(); gp_if j();
  m u(.a(i), .b(j), .c(c), .d(d));
endmodule
