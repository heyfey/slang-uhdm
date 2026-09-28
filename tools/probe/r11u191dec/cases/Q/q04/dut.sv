// (r11u191 queue twin) control: a FIXED-SIZE unpacked-array typedef return keeps the listing builder's bytes
module top;
  typedef int arr_t[4];
  function automatic arr_t mk();
    arr_t a = '{default: 0};
    return a;
  endfunction
endmodule
