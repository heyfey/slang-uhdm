// § ifacePortMemberHighConnParent257 (the child is a program instance whose input port takes the member)
interface rif; logic valid; logic [7:0] address; modport register(input valid, input address); endinterface
program prg(input logic [7:0] a); initial $display(a); endprogram
module common(rif.register register_if); prg pp(.a(register_if.address)); endmodule
module top; rif r(); common u(.register_if(r)); endmodule
