// § escBlockNameSpanTrailSpace286
module top;
  int r;
  task automatic t();
    begin : \tb#1 
      r = 2;
    end
  endtask
  initial t();
endmodule
