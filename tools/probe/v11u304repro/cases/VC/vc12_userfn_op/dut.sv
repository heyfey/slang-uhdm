// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  function automatic logic [1:0] f(logic [1:0] v); return v ^ 2'b01; endfunction
  if (1) begin : g
    assign y = f(idx_t'(a)) + 2'd1;
  end
endmodule
