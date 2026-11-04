// § timeModVarIsNet406
module top;
  time t1, t2;
  initial begin
    t1 = $time;
    t2 = t1 + 5;
  end
endmodule
