// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
  function automatic int f(int a); return a; endfunction
endpackage
class C;
  localparam M = glb::f(glb::arr[1]);
endclass
module test;
endmodule
