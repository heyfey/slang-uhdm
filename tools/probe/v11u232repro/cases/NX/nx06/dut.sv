// § structCopyNestedAnnotDeep232
package p;
  typedef struct packed { logic [3:0] a; logic f; } ucfg_t;
  typedef struct packed { ucfg_t u; logic [3:0] d; } cfg_t;
  function automatic cfg_t build(input int x);
    cfg_t r;
    r.u.a = 4'(x);
    r.u.f = 1'b1;
    r.d = 4'(x + 1);
    return r;
  endfunction
endpackage
// module-local localparam from a package function; two instances with different arguments
module child import p::*; #(parameter int X = 1) (output logic [3:0] w);
  localparam cfg_t C = build(X);
  assign w = C.u.a + C.d;
endmodule
module top(output logic [3:0] w1, output logic [3:0] w2);
  child #(.X(2)) a (.w(w1));
  child #(.X(5)) b (.w(w2));
endmodule
