// § forceIsForceObj401
module top(input f, a, b, output wire q);
  assign q = a & b;
  initial begin
    force q = (a | b);
    #1 release q;
  end
endmodule
