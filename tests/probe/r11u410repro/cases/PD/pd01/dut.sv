// § clsMethodDimRefColons410
class myclass;
  localparam int N = 2;
  extern function void subr(int x[N]);
endclass
function void myclass::subr(int x[N]); endfunction
module test;
endmodule
