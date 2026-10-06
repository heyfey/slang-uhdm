// § ifacePortMemberHighConnParent257 (a bit select of the member and the whole member on two children)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, output logic o); assign o = ^x; endmodule
module bdec(input logic x, output logic o); assign o = x; endmodule
module common(rif.register register_if, output logic o, output logic o2);
  dec d(.x(register_if.address), .o(o)); bdec b(.x(register_if.address[3]), .o(o2)); endmodule
module top; rif r(); logic o, o2; common u(.register_if(r), .o(o), .o2(o2)); endmodule
