// § paramInitCallArgLeafScoped292
package q2;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: 4'h6, cfg: 2'b11 };
  function automatic logic [1:0] pf(logic [1:0] x); return x; endfunction
endpackage
module sub #(parameter logic [1:0] X = q2::pf(q2::IMPL.cfg), parameter logic [1:0] Y = 2'b0) (output logic [1:0] o);
  assign o = X ^ Y;
endmodule
module top(output logic [1:0] o, output logic [1:0] o2);
  function automatic logic [1:0] f(logic [1:0] x); return ~x; endfunction
  sub u1(.o(o));
  sub #(.Y(f(q2::IMPL.s.a))) u2(.o(o2));
endmodule
