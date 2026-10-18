// § parenlessArrMethodIsCall401
module top();
  int s[] = {10, 10, 3};
  int qi[$];
  initial begin
    qi = s.unique;
    $display("%d", qi.size);
    qi.sort;
  end
endmodule
