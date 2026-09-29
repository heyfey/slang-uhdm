// § ifArrElemLitCaFresh225 (the array sized by a parameter, the module instantiated with two sizes)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module m #(parameter int N = 2) (output logic o);
  bi b[N]();
  assign b[N-1].w = 1'b1;
  assign o = b[N-1].w;
endmodule
module top(output logic o1, output logic o2);
  m #(.N(2)) u1(.o(o1));
  m #(.N(3)) u2(.o(o2));
endmodule
