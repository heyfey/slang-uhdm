// § incDecIpsWholeSpan288 — indexed part-select increments in expression positions: an operand, an if condition and a call argument
module top(input logic clk, input logic [2:0] k, output logic [7:0] a, output logic [7:0] y);
  function automatic logic [7:0] f(logic [7:0] v); return v; endfunction
  always_ff @(posedge clk) begin
    y = a[k +: 2]++ + 1;
    if (a[k -: 2]-- > 1) y = f(++a[k +: 3]);
  end
endmodule
