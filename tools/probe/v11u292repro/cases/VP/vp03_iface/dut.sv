// § paramInitCallArgLeafScoped292
package q2;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } in_t;
  typedef struct packed { logic [3:0] pad; in_t s; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{ pad: 4'h9, s: 4'h6, cfg: 2'b11 };
  function automatic logic [1:0] pf(logic [1:0] x); return x; endfunction
endpackage
interface ifc;
  function automatic logic [1:0] f(logic [1:0] x); return ~x; endfunction
  localparam logic [1:0] X = f(q2::IMPL.cfg);
  parameter int W = $bits(f(q2::IMPL.cfg));
  logic [1:0] z;
  assign z = X;
endinterface
module top; ifc i(); endmodule
