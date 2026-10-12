// § ifUnsizedUserCallAbstains305v
package pk;
  function automatic logic [7:0] f(logic x); return {8{x}}; endfunction
endpackage
interface bif();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = pk::f(sig) | '0;
endinterface
module top;
  bif b0();
  bif b1();
endmodule
