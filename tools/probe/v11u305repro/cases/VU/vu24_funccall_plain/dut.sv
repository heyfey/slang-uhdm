// § ifUnsizedUserCallAbstains305v
interface bif();
  logic sig;
  logic [7:0] w;
  function automatic logic [7:0] f(logic x); return {8{x}}; endfunction
  assign w = f(sig) ^ '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
