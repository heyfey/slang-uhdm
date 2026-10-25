// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
endpackage
class C;
  parameter N = 1;
  localparam M = glb::arr[N];
endclass
module test;
endmodule
