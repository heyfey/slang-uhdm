// § paramInitCallArgLeafScoped292
package q2;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: 4'h6, cfg: 2'b11 };
endpackage
module top(output logic [3:0] o);
  function automatic logic [3:0] f(logic [3:0] x); return ~x; endfunction
  localparam logic [3:0] A = f($bits(q2::IMPL.cfg));
  localparam logic [3:0] B = f(4'($unsigned(q2::IMPL.cfg)));
  localparam logic [3:0] C = f(q2::IMPL.s);
  localparam logic [3:0] D = f(4'(q2::IMPL.cfg));
  localparam logic [3:0] E = f(q2::IMPL.pad);
  parameter  logic [3:0] F = f(q2::IMPL.s.a);
  assign o = A ^ B ^ C ^ D ^ E ^ F;
endmodule
