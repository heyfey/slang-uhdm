// § ifacePortMemberHighConnParent257 (the child connected with .* where no name matches, plus the member by name)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, output logic o); assign o = ^x; endmodule
module common(rif.register register_if, output logic o); dec d(.x(register_if.address), .*); endmodule
module top; rif r(); logic o; common u(.register_if(r), .o(o)); endmodule
