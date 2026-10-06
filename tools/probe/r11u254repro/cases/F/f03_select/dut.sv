// § forInitSelectLhsBase254 (an array element and a bit-select as the for-loop initializer target, in a task and a function)
module top(output int o);
  int arr [4];
  logic [7:0] v;
  task automatic t(); for (arr[0] = 0; arr[0] < 3; arr[0]++) o = o + 1; endtask
  function automatic int f(); int r = 0; for (v[3:0] = 0; v[3:0] < 3; v[3:0]++) r++; return r; endfunction
  initial begin o = 0; t(); o = o + f(); end
endmodule
