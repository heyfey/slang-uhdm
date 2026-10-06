// § ifacePortHcConnOrder257v (two children, each taking the member on two ports in reversed order)
interface rif; logic [7:0] address; logic [7:0] data; modport register(input address, input data); endinterface
module dec(input logic [7:0] x, input logic [7:0] y, output logic o); assign o = x[0] ^ y[1]; endmodule
module common(rif.register register_if, output logic o1, output logic o2);
  dec d1(.y(register_if.data), .x(register_if.address), .o(o1));
  dec d2(.o(o2), .y(register_if.address), .x(register_if.data)); endmodule
module top; rif r(); logic o1, o2; common u(.register_if(r), .o1(o1), .o2(o2)); endmodule
