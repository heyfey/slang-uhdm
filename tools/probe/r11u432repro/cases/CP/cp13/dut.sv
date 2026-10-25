// § clsParamCallArgPkgSel432
package p;
  localparam int arr[3] = '{1,2,3};
  function int f(int a); return a; endfunction
  class C;
    parameter N = 1;
    localparam M = f(arr[N]);
  endclass
endpackage
module test;
endmodule
