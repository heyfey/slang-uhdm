// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  typedef struct packed { logic [B.D-1:0] d; logic w; } req_t;
endpackage
module sub import p::*; (input req_t i, output logic o);
  assign o = i.w;
endmodule
module top (input logic [8:0] i, output logic o);
  sub u (.i(i), .o(o));
endmodule
