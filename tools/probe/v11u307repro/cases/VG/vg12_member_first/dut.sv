// § defGenUdpFormNoStmt307
typedef struct packed { logic x; logic z; } s_t;
module leaf (output logic o, input logic i); assign o = ~i; endmodule
module outer (input logic a, output s_t y);
  if (1) begin : g
    leaf u_l (y.x, a);
  end
  assign y.z = a;
endmodule
module dut (input logic a, output s_t y);
  outer u1 (.a(a), .y(y));
endmodule
