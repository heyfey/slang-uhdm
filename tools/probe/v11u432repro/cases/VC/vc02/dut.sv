// § clsParamCallArgPkgSel432
package glb;
  localparam int arr[3] = '{1,2,3};
endpackage
class C;
  localparam M = $clog2(glb::arr[2]);
endclass
module test;
endmodule
