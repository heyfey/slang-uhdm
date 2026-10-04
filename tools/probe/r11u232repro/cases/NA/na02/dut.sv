// § structCopyNestedAnnotDeep232
package p;
  typedef struct packed {
    int unsigned x;
    bit e;
  } inner_t;
  typedef struct packed {
    inner_t i;
    int unsigned a;
  } mid_t;
  typedef struct packed {
    mid_t m;
    int unsigned d;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.m.i.x = 3;
    r.m.i.e = 1'b1;
    r.m.a = 4;
    r.d = 9;
    return r;
  endfunction
  localparam cfg_t C = build();
endpackage
module child import p::*; #(parameter cfg_t Cfg = '0) (output logic [Cfg.m.i.x-1:0] w);
  assign w = '1;
endmodule
module top import p::*; #(parameter cfg_t Cfg = p::C) (output logic [2:0] w);
  child #(.Cfg(Cfg)) u_c (.w(w));
endmodule
