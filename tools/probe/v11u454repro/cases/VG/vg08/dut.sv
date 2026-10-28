// § genericIfcPortRunSharedTs454
interface bus_if; logic [7:0] x; logic v; modport mp(input x, output v); endinterface
interface gp_if; logic [7:0] x; logic v; endinterface
module m(interface a,
         interface b);
  assign b.v = a.x[2];
endmodule
module w(interface p, interface q);
  m mm(.a(p), .b(q));
endmodule
module top;
  bus_if i(); gp_if j();
  w ww(.p(i), .q(j));
endmodule
