// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(interface a, interface b, output logic [7:0] o);
  assign o = b.x;
  assign a.v = 1'b1;
endmodule
module top(output logic [7:0] o);
  bus_if i(); gp_if j();
  m u(i, j, o);
endmodule
