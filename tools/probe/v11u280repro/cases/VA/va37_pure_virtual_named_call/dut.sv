// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a pure virtual prototype implemented below, a named-argument call inside the index (abstains)
package pk;
  virtual class b;
    pure virtual function logic [7:0] get(int idx);
  endclass
  class d extends b;
    logic [7:0] value [4][4];
    function int ix(int a); return a; endfunction
    virtual function logic [7:0] get(int idx); return value[ix(.a(idx))][1] ^ value[idx][2]; endfunction
  endclass
endpackage
module top; pk::d x; initial x = new; endmodule
