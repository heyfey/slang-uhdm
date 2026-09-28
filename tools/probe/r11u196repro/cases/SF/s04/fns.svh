`define FML(t) t value
  function automatic int f(`FML(bs_t), input it_t arr [2]);
    return value + arr[0];
  endfunction
