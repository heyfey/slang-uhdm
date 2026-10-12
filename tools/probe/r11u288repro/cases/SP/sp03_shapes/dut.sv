// § streamPartSelLazyName288 — parameter bounds, an indexed part-select, a nested concatenation, a stream target, a port actual and a call argument
module s(input logic [7:0] i, output logic [7:0] o); assign o = i; endmodule
module top #(parameter int W = 8, parameter int H = 4)(input logic [15:0] x, input logic [2:0] k, output logic [7:0] a, b, c, d, e, f);
  logic [3:0] p, q;
  function automatic logic [7:0] id(input logic [7:0] v); return v; endfunction
  assign a = {<< 2 {x[W-1:H], x[H-1:0]}};
  assign b = {<< 2 {x[k +: 4], x[7 -: 4]}};
  assign c = {<< 4 {{x[3:0], x[7:4]}}};
  always_comb {>> {p, q}} = x[7:0];
  always_comb {<< 2 {e[7:4], e[3:0]}} = x[15:8];
  s u(.i({<< 2 {x[11:8], x[3:0]}}), .o(d));
  assign f = id({<< 2 {x[5:2], x[15:12]}});
endmodule
