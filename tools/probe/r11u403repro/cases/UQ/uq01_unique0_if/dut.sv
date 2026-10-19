// § unique0IfIsUnique403
module top();
  wire [3:0] a = 0;
  reg [1:0] b = 0;
  always @* begin
    unique0 if (a == 0) b = 1;
    else if (a == 1) b = 2;
    unique0 if (a == 3) b = 0;
  end
endmodule
