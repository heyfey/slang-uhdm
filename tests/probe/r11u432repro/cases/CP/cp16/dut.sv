// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
endpackage
class C;
  localparam M = glb::arr[1];
endclass
module test;
endmodule
