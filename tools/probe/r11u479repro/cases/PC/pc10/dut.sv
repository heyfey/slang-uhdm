// § parenCallCallee479
class C;
  int v;
  function int twice(int a); return 2*a; endfunction
endclass
function automatic C dmk(int a); C c = new; return c; endfunction
module top(output int z);
  initial z = (dmk(51).twice(52));
endmodule
