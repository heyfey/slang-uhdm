// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
endpackage
function int f(int a, int b);
  return a + b;
endfunction
class C;
  parameter N = 2;
  localparam M = f(glb::arr[N], N);
endclass
module test;
endmodule
