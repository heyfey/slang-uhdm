// § ifacePortHcConnOrder257v (the last connection's actual comes from a macro defined above the instance)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] y, input logic [7:0] x, output logic o); assign o = x[0] ^ y[1]; endmodule
`define ADDR register_if.address
module common(rif.register register_if, output logic o);
  dec d(.x(register_if.address), .o(o), .y(`ADDR)); endmodule
module top; rif r(); logic o; common u(.register_if(r), .o(o)); endmodule
