// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
endpackage
function int f(int a);
  return a;
endfunction
class C;
  localparam M = f(glb::arr[1]);
endclass
module test;
endmodule
