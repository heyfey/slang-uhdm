// § ifacePortHcConnOrder257v (one child takes the same member on two ports, written in reversed order: the last connection written)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, input logic [7:0] y, output logic o); assign o = x[0] ^ y[1]; endmodule
module common(rif.register register_if, output logic o); dec d(.y(register_if.address), .x(register_if.address), .o(o)); endmodule
module top; rif r(); logic o; common u(.register_if(r), .o(o)); endmodule
