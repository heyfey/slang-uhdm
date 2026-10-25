// § clsParamCallArgPkgSel432
function int f(int a);
  return a;
endfunction
class C;
  parameter N = 2;
  localparam M = f(N) + 1;
endclass
module test;
endmodule
