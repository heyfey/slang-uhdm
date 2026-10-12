// § ifFillBitSelConstIdx303v
interface bus_t2 #(parameter bit P = 0, parameter int K = 1)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[K] = (P) ? {2{sig}} : '0;
endinterface
module top;
  bus_t2 #(.P(0)) b0();
endmodule
