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
  localparam cfg_t C = build(3);
endpackage
// the evaluated struct read by variables, a port and a localparam of the nested type
module top import p::*; (output logic [3:0] w, output ucfg_t uo);
  cfg_t v;
  localparam ucfg_t LU = C.u;
  assign v = C;
  assign w = v.u.a;
  assign uo = LU;
endmodule
