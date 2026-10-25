// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
  function int g(int a); return a; endfunction
endpackage
class C;
  parameter N = 2;
  localparam M = glb::g(glb::arr[N]);
endclass
module test;
endmodule
