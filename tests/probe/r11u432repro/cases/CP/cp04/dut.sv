// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
endpackage
class C;
  parameter N = 2;
  localparam M = glb::arr[N] + 1;
endclass
module test;
endmodule
