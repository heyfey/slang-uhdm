// § streamPartSelLazyName288 — a part-select operand of a streaming concatenation: continuous assignment, process, with and without slice size, beside a plain concatenation (control)
module d29(input logic [7:0] i, output logic [7:0] t0, t1, t2, t3, t4, o1, o2);
  assign o1 = {<< 2 {i[3:0], 4'h1}};
  assign o2 = {i[3:0], 4'h1};
  always_comb begin
    t0 = {<< 2 {i[3:0], 4'h1}};
    t1 = {i[3:0], 4'h1};
    t2 = {<< 2 {i[3:0]}};
    t3 = {<< 2 {i[1], i[3:0], 3'h1}};
    t4 = {>> 2 {i[3:0], 4'h1}};
  end
endmodule
