// § incDecIpsWholeSpan288 — an indexed part-select increment born in a macro, and one whose index is itself a part-select increment target name
`define INC(x) x++
module top(input logic clk, input logic [2:0] k, output logic [7:0] a, output logic [15:0] b);
  logic [3:0] j;
  always_ff @(posedge clk) begin
    `INC(a[k +: 2]);
    b[j[2:0] +: 4]++;
    b[{1'b0, k} -: 2]--;
  end
endmodule
