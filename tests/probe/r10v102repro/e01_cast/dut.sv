module e01;
  parameter W = 'h8;
  parameter V = 'b1010;
  logic [W-1:0] x;
  logic [V-1:0] y;
  initial begin
    x = W'(3);
    y = V'(1);
  end
endmodule
