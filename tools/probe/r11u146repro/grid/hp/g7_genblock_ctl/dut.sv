// § constPathBaseAnyKind146
module top(output logic [7:0] o);
  typedef struct packed { logic [7:0] x; } s_t;
  localparam s_t PS = '{x: 8'd1};
  if (1) begin : g
    assign o = (PS.x == 8'd1) ? 8'd3 : 8'd4;
  end
endmodule
