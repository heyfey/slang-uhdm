// § ifArrElemLitCaFresh225 (a module parameter selector, the module instantiated with two values)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module m #(parameter int K = 0) (output logic o);
  bi b[2]();
  assign b[K].w = 1'b1;
  assign o = b[K].w;
endmodule
module top(output logic o1, output logic o2);
  m #(.K(0)) u1(.o(o1));
  m #(.K(1)) u2(.o(o2));
endmodule
