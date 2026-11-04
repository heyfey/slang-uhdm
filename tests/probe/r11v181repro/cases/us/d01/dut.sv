// § bareDecUnderscoreDropped181 (v11u181 break: delays, replication, repeat, part-select width, a for bound)
module top(input logic clk, output logic [31:0] y);
  logic [31:0] r;
  initial begin
    #1_0 r = 0;
    repeat (1_2) r++;
    for (int i = 0; i < 1_6; i++) r[i] = 1'b1;
    y = {1_0{1'b1}};
    y[4 +: 1_6] = r[1_6 -: 8];
  end
endmodule
