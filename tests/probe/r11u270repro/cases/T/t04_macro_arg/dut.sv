// § sysCallTimeKwNameSpan270
`define CTL(a, b) ctl(a, b)
module top;
  function automatic void ctl(int a, time b);
  endfunction
  initial `CTL(1, $time());
  initial ctl(2, $time( ));
endmodule
