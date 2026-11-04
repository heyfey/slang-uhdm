// § callArgInSelIdxChainName201
class Kk;
  int a[8];
  int s[4];
  function int idx(int v); return v; endfunction
  task t(int k);
    a[idx(s[k])] += 2;
    a[idx(s[idx(s[k])])] = 1;
  endtask
endclass
module n02; Kk kk; endmodule
