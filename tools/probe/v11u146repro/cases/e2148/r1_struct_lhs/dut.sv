// § genLpUintCaRhsOwnCopy148
module top(output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  s_t s;
  generate if (1) begin : g
    localparam L = 5;
    assign s = L;
  end endgenerate
  assign o = s;
endmodule
