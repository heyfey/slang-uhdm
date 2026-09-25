// § nestedDefaultPatLoc147
module top(input logic clk, input logic rst, output logic [2:0] o);
   logic [2:0] a [3:0];
   always_ff @(posedge clk) begin
     if (rst) a <= '{default: '{default: '0}};
     else a[0] <= 3'd1;
   end
   assign o = a[3];
endmodule
