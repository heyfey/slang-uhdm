// § clsParamCallArgPkgSel432
localparam int uarr[3] = '{4,5,6};
function automatic int f(int a); return a; endfunction
class C;
  localparam M = f(uarr[1]);
  localparam K = uarr[2] + 1;
endclass
module test;
endmodule
