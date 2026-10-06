// § ifacePortHcConnOrder257v (the whole instance written by one macro, the connections reversed inside its body)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, input logic [7:0] y, output logic o); assign o = x[0] ^ y[1]; endmodule
`define INST(n) dec n(.o(o), .y(register_if.address), .x(register_if.address));
module common(rif.register register_if, output logic o);
  `INST(d) endmodule
module top; rif r(); logic o; common u(.register_if(r), .o(o)); endmodule
