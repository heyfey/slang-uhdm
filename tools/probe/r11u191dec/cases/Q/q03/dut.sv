// (r11u191 queue twin) an associative-array typedef returned by a module function
module top;
  typedef int tab_t[string];
  function automatic tab_t mk();
    tab_t t;
    return t;
  endfunction
endmodule
