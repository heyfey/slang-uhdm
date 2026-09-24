// § pkgQualCallQualSpan131
// case c01: a package function call without arguments in a parameter default
package p;
  function automatic int f();
    return 5;
  endfunction
endpackage
module sub #(parameter int P = p::f()) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
