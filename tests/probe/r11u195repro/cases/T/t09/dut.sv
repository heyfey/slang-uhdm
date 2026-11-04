// § tagPatParenSpan195 — grid T/t09 (r11u195)
module top (output logic [7:0] o, output logic [7:0] p);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t s, t;
  always_comb begin
    s = '{a: ((4'd1)), b: 4'd2};
    t = '{default: 4'd0, a: (4'd3)};
  end
  assign o = s;
  assign p = t;
endmodule
