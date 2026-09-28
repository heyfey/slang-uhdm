// § pkgPatReadTsBindsTopTypedef192
package p;
  typedef struct packed { logic [7:0] A; logic [7:0] D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  function automatic int f(cfg_t c); return c.D; endfunction
endpackage
module top #(parameter int W = p::f(p::B)) (input logic [W-1:0] i, output logic o);
  assign o = i[0];
endmodule
