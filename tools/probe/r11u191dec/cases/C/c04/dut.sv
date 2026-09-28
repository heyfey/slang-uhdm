// (r11u191 const call) a cast behind a condition that is not executed, and a cast of a formal inside an expression
module top (output int o1, output int o2);
  typedef logic signed [31:0] imm_t;
  function automatic int k1(int x); if (x > 0) return x; return imm_t'(x); endfunction
  function automatic int k2(logic [11:0] x); k2 = imm_t'(x) + 1; endfunction
  assign o1 = k1(3);
  assign o2 = k2(12'h7);
endmodule
