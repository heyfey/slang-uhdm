// § incDecIpsWholeSpan288 — indexed part-select increments of an unpacked element, a two-dimension packed array, with a parameter width overridden, and in a for-generate in both views
module m #(parameter int W = 2)(input logic clk, input logic [2:0] k, output logic [7:0] o [4], output logic [1:0][7:0] p);
  always_ff @(posedge clk) begin
    o[1][k +: W]++;
    p[1][k -: W]--;
    o[k[1:0]][k +: 2]++;
  end
  for (genvar g = 0; g < 2; g++) begin : gl
    always_ff @(posedge clk) o[g + 2][g +: W]++;
  end
endmodule
module top(input logic clk, input logic [2:0] k, output logic [7:0] o [4], output logic [1:0][7:0] p); m #(.W(3)) u(.*); endmodule
