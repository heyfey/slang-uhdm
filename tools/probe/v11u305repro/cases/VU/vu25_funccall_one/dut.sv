// § ifUnsizedUserCallAbstains305v
interface bif();
  logic sig;
  logic [7:0] arr[2];
  function automatic logic [7:0] f(logic x); return {8{x}}; endfunction
  assign arr[0] = f(sig) | '0;
endinterface
module top;
  bif b0();
endmodule
