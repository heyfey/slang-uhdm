// § patFlatTernPickedLeafSpan250
// a struct localparam with picked members in a generate block and in a child at depth 2
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module leaf #(parameter s_t P = '{a: 4'd1, b: 4'd2}) (output logic [3:0] o);
  localparam s_t Q = '{a: P.b, b: 0 ? P.a : 4'd8};
  assign o = Q.a ^ Q.b;
endmodule
module mid(output logic [3:0] o);
  localparam s_t M = '{a: 4'd3, b: 4'd4};
  leaf #(.P(M)) l(.o(o));
endmodule
module top(output logic [3:0] o, g);
  mid m(.o(o));
  if (1) begin : gb
    localparam s_t G = '{a: 4'd5, b: 4'd6};
    localparam s_t H = '{a: G.b, b: 1 ? G.a : 4'd0};
    assign g = H.a;
  end
endmodule
