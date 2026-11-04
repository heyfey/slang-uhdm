// § timeModVarIsNet406
module top;
  time a;
  initial begin
    a = $time;
    $display(a);
  end
endmodule
