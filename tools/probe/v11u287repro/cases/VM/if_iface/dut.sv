// § evalFuncKeepOwnParamAddCmp287v
interface ifc #(parameter int N = 3); logic [31:0] o;
  function automatic int f(int a); int r; r = a * N; return r; endfunction
  assign o = f(5);
endinterface
module m(output logic [31:0] y); ifc u(); assign y = u.o; endmodule
