// § clsParamCallArgPkgSel432
module test;
  function automatic int f(int a); return a; endfunction
  class C;
    localparam M = f(5);
  endclass
  C c;
endmodule
