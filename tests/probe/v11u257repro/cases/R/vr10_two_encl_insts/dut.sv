// § ifacePortMemberHighConnParent257 (two instances of the enclosing module, each bound to its own interface instance)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, output logic o); assign o = ^x; endmodule
module common(rif.register register_if, output logic o); dec d(.x(register_if.address), .o(o)); endmodule
module top; rif r1(); rif r2(); logic o1, o2; common u1(.register_if(r1), .o(o1)); common u2(.register_if(r2), .o(o2)); endmodule
