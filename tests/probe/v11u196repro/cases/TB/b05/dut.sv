// § tpArrBoundAtLeftOperand196: the vector-typedef emitter (emitVectorTypedefArrayVar) with a product and a power on the left
module dut #(parameter int N = 3) (output logic [3:0] o);
  typedef logic [3:0] v_t;
  v_t [N*2-1:0] a;
  v_t [2**N-1:0] b;
  assign o = a[0] ^ b[0];
endmodule
