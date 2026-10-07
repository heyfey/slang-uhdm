// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a class nested in a package class reading a handle's member with two selects, called through a static method
package pk;
  class outer;
    class inner; logic [7:0] value [4][4]; endclass
    class user;
      inner h;
      function logic [7:0] f(int idx); return h.value[idx][2]; endfunction
    endclass
  endclass
endpackage
module top; pk::outer::user u; initial u = new; endmodule
