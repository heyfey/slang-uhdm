// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// this. paths with two selects in a class method beside a plain member read
package pk;
  class c;
    logic [7:0] value [4][4];
    function logic [7:0] f(int idx); return this.value[idx][1] ^ value[idx][0]; endfunction
  endclass
endpackage
module top; pk::c x; initial x = new; endmodule
