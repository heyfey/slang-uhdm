// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(input logic e, interface a, interface b);
  assign a.v = b.x[0] & e;
endmodule
module top(input logic e);
  bus_if i(); gp_if j();
  m u(.e(e), .a(i), .b(j));
endmodule
