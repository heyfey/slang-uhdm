// § unitArrTd245
// a $unit fixed array typedef as a module function's formal, local and in a task
typedef int ia_t[3];
module top;
  function automatic int sum(ia_t x);
    ia_t y;
    y = x;
    return y[0] + y[1] + y[2];
  endfunction
  int r;
  initial r = sum('{1, 2, 3});
endmodule
