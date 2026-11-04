module top;
  int r;
  function automatic int f(int a);
    int arr[$];
    int id;
    arr.push_back(a);
    id = a;
    return id;
  endfunction
  initial r = f(3);
endmodule
