// § tfItemInitLocalAtType209: an unpacked array local with an initializer in a paren-less function
module top;
  function int h;
    int arr [2] = '{1, 2};
    return arr[0];
  endfunction
  int r;
  initial r = h();
endmodule
