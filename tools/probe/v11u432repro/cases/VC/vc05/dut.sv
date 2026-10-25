// § clsParamCallArgPkgSel432
package glb;
  localparam logic [7:0] v = 8'hA5;
  localparam int arr[4] = '{1,2,3,4};
endpackage
function automatic int f(int a, int b); return a + b; endfunction
class C #(int N = 1);
  localparam M = f(glb::arr[N+1], glb::v[3]);
endclass
module test;
  C #(2) c;
endmodule
