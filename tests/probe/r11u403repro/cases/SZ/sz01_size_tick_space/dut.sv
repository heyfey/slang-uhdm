// § sizeTickSpaceDropped403
module top();
  logic [31:0] c;
  logic [15:0] d;
  initial begin
    c = 32 'h 12ab_f001;
    d = 16  'd 77;
  end
endmodule
