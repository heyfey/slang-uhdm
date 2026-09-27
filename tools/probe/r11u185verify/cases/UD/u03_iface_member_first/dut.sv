// § udpFormNetLvalueFirst176
module ch(A, B, C);
    input [1:0] A, B;
    output [1:0] C;
    assign C = A ^ B;
endmodule
interface bus_if; logic [1:0] a, b; endinterface
module dut(bus_if ifc, output [1:0] o);
  ch a1(ifc.a, ifc.b, o);
endmodule
module top(output [1:0] o);
  bus_if bi();
  dut d(bi, o);
endmodule
