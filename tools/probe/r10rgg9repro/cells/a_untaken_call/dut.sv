module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  function automatic logic [7:0] f(logic x);
    return {8{x}};
  endfunction

  assign arr[0] = (P) ? f(sig) : '0;

endmodule
module top;
  m #(.P(0)) u_a();
endmodule
