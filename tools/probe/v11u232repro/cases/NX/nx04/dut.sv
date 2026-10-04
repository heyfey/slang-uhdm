// § structCopyNestedAnnotDeep232
package p;
  typedef struct packed { logic [3:0] a; logic f; } ucfg_t;
  typedef struct packed { ucfg_t u; logic [3:0] d; } mid_t;
  typedef struct packed { mid_t m; logic g; } cfg_t;
  function automatic cfg_t build(input int x);
    cfg_t r;
    r.m.u.a = 4'(x);
    r.m.u.f = 1'b1;
    r.m.d = 4'(x + 1);
    r.g = 1'b0;
    return r;
  endfunction
  localparam cfg_t C = build(3);
endpackage
// three levels of nesting, evaluated
module child import p::*; #(parameter cfg_t Cfg = '0) (output logic [Cfg.m.u.a-1:0] w, output logic [Cfg.m.d:0] z);
  assign w = '1;
  assign z = '0;
endmodule
module top import p::*; #(parameter cfg_t Cfg = C) (output logic [2:0] w, output logic [4:0] z);
  child #(.Cfg(Cfg)) u_c (.w(w), .z(z));
endmodule
