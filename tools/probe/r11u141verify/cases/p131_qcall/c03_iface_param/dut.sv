// § pkgQualCallQualSpan131
// case c03: package-qualified call as an interface parameter default
package p;
  function automatic int f(int a);
    return a * 2;
  endfunction
endpackage
interface ifc #(parameter int W = p::f(2));
  logic [W-1:0] d;
endinterface
module top(output logic [3:0] o);
  ifc u();
  assign o = u.d;
endmodule
