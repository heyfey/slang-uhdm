module top(input logic [11:0] i, output logic [31:0] o);
  typedef logic signed [32-1:0] imm_t;
  function automatic imm_t f(logic [11:0] x);
    f = imm_t'($signed(x));
  endfunction
  assign o = f(i);
endmodule
