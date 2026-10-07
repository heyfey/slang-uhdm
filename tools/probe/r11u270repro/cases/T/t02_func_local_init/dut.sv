// § sysCallTimeKwNameSpan270
module top;
  function automatic time f();
    time current_time = $time();
    return current_time + $time();
  endfunction
  task automatic g(input int a, time b);
  endtask
  initial g(1, $time());
endmodule
