// § withCallParenSyntax286 — module process (implicit item net shape) and function in module
module top;
  int q[$];
  int r;
  function automatic int f();
    int s;
    s = 3 + (q.sum() with ( item ));
    return s;
  endfunction
  initial r = f();
endmodule
