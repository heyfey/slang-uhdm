// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a class declared inside a module reading a handle's member with two selects, and a nested class in a package
module top(output logic [7:0] o);
  class c; logic [7:0] value [4][4]; endclass
  class d;
    c h;
    function logic [7:0] f(int idx); return h.value[idx][1]; endfunction
  endclass
  d x;
  initial begin x = new; o = x.f(1); end
endmodule
