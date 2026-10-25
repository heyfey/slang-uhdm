// § clsParamCallArgPkgSel432
package glb;
  localparam logic [7:0] v = 8'h5a;
endpackage
function int f(int a);
  return a;
endfunction
class C;
  parameter N = 2;
  localparam M = f(glb::v[N]);
endclass
module test;
endmodule
