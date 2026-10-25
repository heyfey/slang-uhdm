// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[2][2] = '{'{1,2},'{3,4}};
endpackage
function automatic int f(int a); return a; endfunction
class C;
  localparam M = f(glb::arr[1][0]);
endclass
module test;
endmodule
