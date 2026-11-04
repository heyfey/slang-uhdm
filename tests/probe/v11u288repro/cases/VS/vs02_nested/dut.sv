// § streamPartSelLazyName288 — part-selects nested inside a streaming operand: a call argument, an index, an inner concatenation and a part-select of a select
module top(input logic [7:0] i, input logic [7:0] a [4], output logic [7:0] t0, t1, t2, t3);
  function automatic logic [3:0] f(logic [3:0] v); return ~v; endfunction
  always_comb begin
    t0 = {<< {f(i[3:0]), 4'h0}};
    t1 = {<< {a[i[1:0]]}};
    t2 = {<< 2 {{i[3:0], i[7:4]}}};
    t3 = {<< {a[1][3:0], a[2][7:4]}};
  end
endmodule
