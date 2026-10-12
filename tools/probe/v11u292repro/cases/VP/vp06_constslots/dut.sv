// § paramInitCallArgLeafScoped292
package q2;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: 4'h6, cfg: 2'b11 };
endpackage
module top(output logic [7:0] o);
  function automatic int f(logic [1:0] x); return x + 1; endfunction
  localparam logic [7:0] R = {f(q2::IMPL.cfg){2'b01}};
  localparam int W = f(q2::IMPL.s.a) + 2;
  localparam logic [7:0] S = R[f(q2::IMPL.cfg) +: 2];
  localparam logic [7:0] U = R[f(q2::IMPL.cfg):0];
  logic [f(q2::IMPL.cfg):0] w;
  logic [W-1:0] z;
  assign w = '0;
  assign z = '0;
  assign o = R ^ S ^ U;
endmodule
