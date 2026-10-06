// § ifacePortMemberHighConnParent257 (the member is also read by a continuous assignment of the enclosing module)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, output logic o); assign o = ^x; endmodule
module common(rif.register register_if, output logic o, output logic [7:0] a2);
  assign a2 = register_if.address; dec d(.x(register_if.address), .o(o)); endmodule
module top; rif r(); logic o; logic [7:0] a2; common u(.register_if(r), .o(o), .a2(a2)); endmodule
