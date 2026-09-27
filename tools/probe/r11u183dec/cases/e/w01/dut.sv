module top;
  int q[$];
  int r[$];
  initial begin
    r = q.unique( it ) with ( it + 1 );
    r = q.find with (item > 2);
    r = q.find(x) with (x > 2 );
  end
endmodule
