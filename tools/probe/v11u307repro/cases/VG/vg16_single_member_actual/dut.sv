// § defGenOrderedConnPorts307
typedef struct packed { logic x; logic z; } s_t;
module leaf (input logic i); endmodule
module outer (input s_t s);
  if (1) begin : g
    leaf u_l (s.x);
  end
endmodule
module dut (input s_t s);
  outer u1 (.s(s));
endmodule
