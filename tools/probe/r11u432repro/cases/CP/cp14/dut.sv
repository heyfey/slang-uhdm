// § clsParamCallArgPkgSel432
function int f();
  return 4;
endfunction
class C;
  localparam M = f();
endclass
module test;
endmodule
