module sub;
  int r;
  function automatic int f(int a);
    int arr[$];
    int id = 2;
    arr.push_back(a);
    id = a;
    return id;
  endfunction
  initial r = f(3);
endmodule
module top;
  sub u1();
  sub u2();
endmodule
