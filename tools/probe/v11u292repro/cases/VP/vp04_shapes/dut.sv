// § paramInitCallArgLeafScoped292
package q2;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: 4'h6, cfg: 2'b11 };
  function automatic logic [1:0] pf(logic [1:0] x); return x; endfunction
endpackage
module top(output logic [1:0] o);
  function automatic logic [1:0] f(logic [1:0] x, logic [1:0] y = 2'b0); return x ^ y; endfunction
  localparam logic [1:0] A = f(.y(q2::IMPL.cfg), .x(2'b01));
  localparam logic [1:0] B = f(q2::IMPL.cfg[0] ? 2'b1 : 2'b0);
  localparam logic [1:0] C = f({q2::IMPL.s.a[0], 1'b0});
  localparam logic [1:0] D = f(q2::IMPL.cfg) + f(q2::IMPL.s.b);
  localparam int E = $clog2(f(q2::IMPL.cfg) + 1);
  localparam logic [1:0] F = q2::IMPL.cfg + f(2'b0);
  logic [1:0] v;
  always_comb v = f(q2::IMPL.cfg);
  assign o = A ^ B ^ C ^ D ^ F ^ v;
endmodule
