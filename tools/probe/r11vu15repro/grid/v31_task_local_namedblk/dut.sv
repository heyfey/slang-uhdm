module top(input logic clk, input logic [7:0] a, output logic [7:0] o);
  logic [7:0] r;
  task automatic t(input logic [7:0] x, output logic [7:0] y);
    logic [7:0] bs;
    begin : tb
      bs      = x;
      bs[3:0] = 4'hf;
      y       = bs;
    end
  endtask
  always_ff @(posedge clk) t(a, r);
  assign o = r;
endmodule
