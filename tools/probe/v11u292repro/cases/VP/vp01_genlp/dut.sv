// § paramInitCallArgLeafScoped292
package q2;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: 4'h6, cfg: 2'b11 };
  function automatic logic [1:0] pf(logic [1:0] x); return x; endfunction
endpackage
module top(output logic [1:0] o);
  function automatic logic [1:0] f(logic [1:0] x); return ~x; endfunction
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam logic [1:0] X = f(q2::IMPL.cfg);
    localparam logic [1:0] Y = f(q2::IMPL.s.b) ^ 2'b01;
  end
  if (1) begin : ib
    localparam logic [1:0] Z = f(f(q2::IMPL.cfg));
  end
  assign o = gb[0].X;
endmodule
