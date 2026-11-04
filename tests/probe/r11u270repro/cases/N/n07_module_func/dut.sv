// § methArgPathIdxAtHierPath270
class info;
  function string get_name(); return "n"; endfunction
endclass
class holder;
  info arr[4];
  function bit exists(string a);
    return 1;
  endfunction
endclass
module top;
  holder v;
  int r;
  function automatic void t(int i);
    if (v.exists(v.arr[i].get_name())) r = 1;
  endfunction
  initial begin
    for (int k = 0; k < 2; k++)
      if (v.exists(v.arr[k].get_name())) r = 2;
  end
endmodule
