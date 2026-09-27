// § bitSelParenIdxSpan181 (v11u181 break: parenthesized index on a parameter, a localparam in a param init, an unpacked memory, in a generate loop)
module top #(parameter logic [7:0] P = 8'hA5)(input logic [2:0] i, output logic [7:0] y);
  localparam logic L = P[(3)];
  logic [3:0] mem [0:7];
  for (genvar g = 0; g < 2; g++) begin : G
    assign y[g] = P[(g)] ^ mem[(g+1)][0];
  end
  assign y[2] = L ^ P[(i)];
  assign y[3] = mem[(i)][(1)];
endmodule
