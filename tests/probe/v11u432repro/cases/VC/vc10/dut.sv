// § clsParamCallArgPkgSel432
package pk;
  function automatic int g(int a); return a + 1; endfunction
  class C;
    localparam M = g(3);
  endclass
endpackage
function automatic int g(int a); return a; endfunction
module test;
  pk::C c;
endmodule
