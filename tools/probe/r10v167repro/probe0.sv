package p0167;
  function int pf167(int a, int b = 2, int c = 5);
    return a + b + c;
  endfunction
  class sh167 #(type T167 = int);
    int r;
    function void go();
      r = pf167(1);
      r = pf167(T167::nm167);
    endfunction
  endclass
endpackage
