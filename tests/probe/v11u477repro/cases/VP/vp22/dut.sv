// § parenCallWrittenArgs477
interface ifc;
  function automatic int f(int a, int b = 5); return a + b; endfunction
endinterface
module top(output int z);
  ifc u();
  initial z = (u.f(1));
endmodule
