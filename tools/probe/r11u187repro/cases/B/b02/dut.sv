// § modAggTfArgCloneFollows180 (r11u183's paramAggTdLastWriter183, measured redundant by r11u187)
module m #(parameter int K = 1) (output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pr_t;
  function automatic logic [7:0] g1 (pr_t x); g1 = x; endfunction
  function automatic logic [7:0] g2 (input pr_t y); g2 = ~y; endfunction
  localparam pr_t P = '{a: 4'h1, b: 4'h2};
  assign o = K ? g1(P) : g2(P);
endmodule
module top(output logic [7:0] o); m #(.K(0)) u(.o(o)); endmodule
