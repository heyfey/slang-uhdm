// § ifacePortHcConnOrder257v (the reversed connections written over three lines, one through a macro)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, input logic [7:0] y, output logic o); assign o = x[0] ^ y[1]; endmodule
`define ADDR register_if.address
module common(rif.register register_if, output logic o);
  dec d(.y(`ADDR),
        .o(o),
        .x(register_if.address)); endmodule
module top; rif r(); logic o; common u(.register_if(r), .o(o)); endmodule
