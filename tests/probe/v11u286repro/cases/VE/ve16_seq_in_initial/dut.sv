// § escBlockNameSpanTrailSpace286
module top;
  int r;
  initial begin
    begin : \s1 
      r = 1;
    end
    begin : \s2 
      r = 2;
    end
  end
endmodule
