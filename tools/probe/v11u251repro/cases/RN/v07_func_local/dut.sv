// § regTdArrElabIsNet251 (control: a function local and a task local of a reg typedef are not elaborated signals)
typedef reg r_t [4];
module top;
  function automatic logic f(); r_t x; x[0] = 1; return x[0]; endfunction
  task automatic t(); r_t y; y[1] = 0; endtask
  logic o;
  assign o = f();
endmodule
