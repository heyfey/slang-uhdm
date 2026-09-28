  class c;
    function int m(bs_t value);
      return value;
    endfunction
  endclass
  task automatic t(input it_t v, output int r);
    r = v;
  endtask
