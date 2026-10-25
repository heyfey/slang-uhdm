// § clsParamCallArgPkgSel432
function int f(int x);
  return x;
endfunction
class C;
  localparam int a[3] = '{1,2,3};
  parameter N = 1;
  localparam M = f(a[N]);
endclass
module test;
endmodule
