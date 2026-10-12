// § ifUnsizedUserCallAbstains305v
interface bif #(parameter bit P = 0)();
  logic sig;
  logic [7:0] arr[2];
  function automatic logic [7:0] f(logic x); return {8{x}}; endfunction
  assign arr[0] = (P) ? f(sig) : '0;
endinterface
module top;
  bif #(.P(1)) b0();
  bif #(.P(0)) b1();
endmodule
