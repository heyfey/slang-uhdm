// § clsMethodDimRefColons410
package p;
class myclass;
  localparam int N = 2;
  extern function void subr(int x[N]);
  function void f2(logic y[N]); endfunction
endclass
function void myclass::subr(int x[N]); endfunction
endpackage
module test;
endmodule
