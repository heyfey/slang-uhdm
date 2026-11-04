// § modportImplicitHdrNoNetType418
interface bus_if(input clk, input rst);
    logic v;
    modport m(input clk, rst, output v);
    modport s(input clk, input rst, input v);
endinterface
module a(bus_if.m b); assign b.v = b.rst; endmodule
module c(bus_if.s b, output logic o); always @(posedge b.clk) o <= b.v; endmodule
module top;
    logic clk, rst, o;
    bus_if bi(clk, rst);
    a ua(bi);
    c uc(bi, o);
endmodule
