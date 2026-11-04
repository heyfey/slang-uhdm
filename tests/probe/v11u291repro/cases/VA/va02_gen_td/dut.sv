// § anonAggMemberChainName291
module dut (input logic [3:0] a, output logic o);
  if (1) begin : g
    typedef struct packed { struct packed { logic a; logic b; } [1:0] m; } t_t;
    t_t v;
    assign v = a;
    assign o = v.m[1].a;
  end
endmodule
