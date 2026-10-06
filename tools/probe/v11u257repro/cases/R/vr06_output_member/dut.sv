// § ifacePortMemberHighConnParent257 (a child OUTPUT port drives an output modport member)
interface rif; logic [7:0] rdata; logic en; modport register(output rdata, input en); endinterface
module drv(input logic e, output logic [7:0] q); assign q = {8{e}}; endmodule
module common(rif.register register_if); drv d(.e(register_if.en), .q(register_if.rdata)); endmodule
module top; rif r(); common u(.register_if(r)); endmodule
