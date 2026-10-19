// § clsMethodDimRefColons410
package p;
  localparam M = 2;
class C;
  localparam N = 3;
  extern function void f(input int a[N], input int b[M]);
endclass
function void C::f(input int a[N], input int b[M]);
endfunction
endpackage
module top; p::C c = new; endmodule
