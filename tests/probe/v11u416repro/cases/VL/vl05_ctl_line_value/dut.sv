// § lineDirectiveIgnored416
module top;
  localparam int L1 = `__LINE__;
  logic [7:0] a;
  assign a = L1;
endmodule
