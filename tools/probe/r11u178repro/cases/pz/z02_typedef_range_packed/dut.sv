// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct packed { logic [7:0] A; logic [7:0] D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  typedef struct packed { logic [B.D-1:0] d; logic w; } req_t;
endpackage
module top import p::*; (input req_t i, output logic o);
  assign o = i.w;
endmodule
