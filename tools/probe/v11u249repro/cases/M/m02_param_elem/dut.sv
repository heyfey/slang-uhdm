// § modDynArrTd249
module sub #(parameter W = 4);
  typedef logic [W-1:0] q_t[$];
  q_t q;
endmodule
module top; sub #(8) u(); endmodule
