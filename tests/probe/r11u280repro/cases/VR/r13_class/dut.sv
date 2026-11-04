// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue class member two selects in a class method, and through this.
package pk;
  class c;
    logic [31:0] value [4][4];
    function logic [31:0] fa(int idx);
      return value[idx][3];
    endfunction
  endclass
  class d;
    c h;
    function logic [31:0] fb(int idx);
      logic [31:0] o;
      o = h.value[idx][3];
      return o;
    endfunction
  endclass
endpackage
module top; import pk::*; d x; initial x = new; endmodule
