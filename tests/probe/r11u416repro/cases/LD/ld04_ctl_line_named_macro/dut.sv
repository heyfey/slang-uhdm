// § lineDirectiveIgnored416
`define line_w 4
module top();
  logic [`line_w-1:0] a;
  assign a = '0;
endmodule
