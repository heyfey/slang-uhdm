// § ifacePortMemberHighConnParent257 (two interface ports bound to the SAME instance; each child reads a different port)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, output logic o); assign o = ^x; endmodule
module common(rif.register a_if, rif.register b_if, output logic o1, output logic o2);
  dec d1(.x(b_if.address), .o(o1)); dec d2(.x(a_if.address), .o(o2)); endmodule
module top; rif r1(); logic o1, o2; common u(.a_if(r1), .b_if(r1), .o1(o1), .o2(o2)); endmodule
