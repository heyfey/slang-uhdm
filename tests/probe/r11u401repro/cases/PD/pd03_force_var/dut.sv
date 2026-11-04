// § forceIsForceObj401
module top();
  logic [3:0] v;
  initial begin
    force v = 4'h3;
    #5 release v;
  end
endmodule
