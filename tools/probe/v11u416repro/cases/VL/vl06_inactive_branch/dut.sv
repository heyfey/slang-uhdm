// § lineDirectiveIgnored416
module top;
`ifdef NOTDEF
`line 5 "x.sv" 1
`endif
  logic a;
  assign a = 1'b1;
endmodule
