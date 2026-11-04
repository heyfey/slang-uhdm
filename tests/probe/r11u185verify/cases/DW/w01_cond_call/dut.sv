// § doWhileSpansToCloseParen175 § doWhileEndsAtCondEnd178v
module top;
  int i, q[$];
  function automatic bit more(int x); return x < 3; endfunction
  initial begin
    do i++; while (more(i));
    do q.push_back(i); while (q.size() < 4);
    do i--; while ($countones(i) > 1);
  end
endmodule
