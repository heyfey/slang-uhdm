// § elabPkgQualRefRhsPkgTs278
package p; parameter A = 2; endpackage
module m(output int o); parameter K = p::A;
  function automatic int f(int x = K); return x; endfunction
  assign o = f();
endmodule
