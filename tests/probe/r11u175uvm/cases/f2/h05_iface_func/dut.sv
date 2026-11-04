interface ifc;
  int r;
  function automatic int f(int a);
    int arr[$];
    int id;
    arr.push_back(a);
    id = a;
    return id;
  endfunction
endinterface
module top;
  ifc i();
  int r;
  initial r = i.f(3);
endmodule
