// § clsParamCallArgPkgSel432
function int f(int a);
  return a;
endfunction
class C;
  parameter N = 2;
  localparam M = f(f(N));
endclass
module test;
endmodule
