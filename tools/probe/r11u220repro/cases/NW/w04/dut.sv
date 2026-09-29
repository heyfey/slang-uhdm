// r11u220 decode (control): new[] size and call-argument names
module top;
  function void f(int n_bytes);
    int local_addr[];
    local_addr = new[n_bytes];
  endfunction
endmodule
