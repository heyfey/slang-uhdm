// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(interface a, interface b);
  always_comb a.v = b.x[3];
  initial begin
    b.v = a.x[0];
  end
endmodule
module top;
  gp_if i(); gp_if j();
  m u(.a(i), .b(j));
endmodule
