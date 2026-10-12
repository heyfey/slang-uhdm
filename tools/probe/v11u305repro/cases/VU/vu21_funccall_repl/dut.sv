// § ifUnsizedUserCallAbstains305v
interface bif();
  logic sig;
  logic [7:0] arr[2];
  function automatic logic g(logic x); return ~x; endfunction
  assign arr[1] = {8{g(sig)}} & '1;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
