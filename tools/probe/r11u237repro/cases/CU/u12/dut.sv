// § unionRetVarAtTypeToken237
// a package union typedef returned by a package function
package p;
  typedef union packed { int unsigned i; bit [31:0] v; } u_t;
  function automatic u_t f(int unsigned a);
    u_t r;
    r.i = a;
    return r;
  endfunction
endpackage
module top(output logic [31:0] o);
  assign o = p::f(3);
endmodule
