// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  task automatic t();
    r = 2 + (q.sum() with ((q.sum() with (item)) + item));
  endtask
  initial t();
endmodule
