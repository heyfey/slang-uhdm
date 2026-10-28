// § genericIfcPortRunSharedTs454
interface ia; logic x; endinterface
interface ib; logic y; endinterface
module s(interface bus, input logic c, interface gpio, interface third);
  always @(posedge c) bus.x <= gpio.y;
endmodule
module s2(interface p);
  initial p.x = 0;
endmodule
module top;
  logic c;
  ia u1(); ib u2(); ia u3();
  s dut(.bus(u1), .c(c), .gpio(u2), .third(u3));
  s2 d2(.p(u1));
endmodule
