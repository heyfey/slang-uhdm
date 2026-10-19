// § operatorAttrsListed403
module top();
  logic [7:0] a, b, c;
  initial begin
    a = b + (* mode = "cla" *) c;
  end
endmodule
