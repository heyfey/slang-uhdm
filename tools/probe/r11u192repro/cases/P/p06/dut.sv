// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  typedef cfg_t cfg2_t;
  localparam cfg2_t B = '{A:2, D:8};
  typedef struct packed { logic [B.D-1:0] d; logic w; } req_t;
endpackage
module top import p::*; (input req_t i, output logic o);
  assign o = i.w;
endmodule
