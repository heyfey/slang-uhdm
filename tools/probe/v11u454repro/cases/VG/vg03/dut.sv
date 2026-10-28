// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
interface outer(interface a, interface b);
  logic z;
  assign z = a.x[0] & b.x[0];
endinterface
module top;
  bus_if i(); gp_if j();
  outer o(i, j);
endmodule
