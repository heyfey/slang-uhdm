// § pkgRetBitSelParamFold407
package p;
  localparam int RB = 2;
  typedef logic [3:0] arr_t [4];
  function automatic logic [3:0] f(arr_t a);
    return a[RB] & a[0];
  endfunction
endpackage
module top(input p::arr_t i, output logic [3:0] o);
  assign o = p::f(i);
endmodule
