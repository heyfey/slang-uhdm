// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
endpackage
function int f(int a);
  return a;
endfunction
class C;
  parameter N = 2;
  localparam M = f(glb::arr[N+0]);
endclass
module test;
endmodule
