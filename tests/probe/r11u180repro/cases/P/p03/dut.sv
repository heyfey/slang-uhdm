// § pkgAggTfArgCloneFollows180
package p;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  function automatic logic [7:0] get(input u_t u);
    return u.a;
  endfunction
  localparam u_t U = 8'h5;
endpackage
module top import p::*; (output logic [7:0] y);
  assign y = U.b;
endmodule
