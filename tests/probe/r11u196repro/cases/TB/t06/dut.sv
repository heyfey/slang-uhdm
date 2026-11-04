// § tpArrBoundAtLeftOperand196: the vector-typedef packed array (the emitter sharing the reading), compound left operands
module dut #(parameter int N = 3) (output logic [3:0] o);
  typedef logic [3:0] w_t;
  w_t [2**N-1:0] a;
  w_t [N+N-1:0] b;
  w_t [(N)-1:0] c;
  assign o = a[0] ^ b[0] ^ c[0];
endmodule
