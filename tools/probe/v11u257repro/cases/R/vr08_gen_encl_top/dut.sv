// § ifacePortMemberHighConnParent257 (the enclosing module is instantiated inside a generate loop of the top, an interface array)
interface rif; logic [7:0] address; modport register(input address); endinterface
module dec(input logic [7:0] x, output logic o); assign o = ^x; endmodule
module common(rif.register register_if, output logic o); dec d(.x(register_if.address), .o(o)); endmodule
module top; rif r[2](); logic [1:0] o;
  for (genvar i = 0; i < 2; i++) begin : g common u(.register_if(r[i]), .o(o[i])); end endmodule
