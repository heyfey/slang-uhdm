// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// class methods: a static method, an extern method, a handle path two hops
package pk;
  class c;
    logic [7:0] value [4][4];
    static logic [7:0] sv [4][4];
    extern function logic [7:0] fe(int idx);
    static function logic [7:0] fs(int idx); return sv[idx][1]; endfunction
  endclass
  function logic [7:0] c::fe(int idx); return value[idx][2]; endfunction
  class d;
    c h;
    function logic [7:0] fb(int idx); return h.value[idx][3] ^ h.sv[1][idx]; endfunction
  endclass
endpackage
module top; import pk::*; d x; initial x = new; endmodule
