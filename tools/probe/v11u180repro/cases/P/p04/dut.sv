// § pkgAggTfArgCloneFollows180 (verifier: a module's package-qualified formal is the only writer)
package p;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  localparam u_t U = 8'h5;
endpackage
module top (output logic [7:0] y);
  function automatic logic [7:0] get(input p::u_t u);
    return u.a;
  endfunction
  assign y = get(p::U);
endmodule
