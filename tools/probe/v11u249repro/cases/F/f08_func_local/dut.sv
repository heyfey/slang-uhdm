// § modTdElabFoldSize249
module top;
  typedef int f_t[4];
  f_t x;
  function automatic int g(); f_t l; l[0] = 1; return l[0]; endfunction
  int r;
  initial r = g();
endmodule
