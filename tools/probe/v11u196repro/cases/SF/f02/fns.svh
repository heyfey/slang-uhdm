function automatic int f1(input `FT(b8_t) v);
  return v;
endfunction
task automatic t1(output b16_t o, ref b8_t r);
  o = r;
endtask
