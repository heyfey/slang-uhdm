// § withCallParenSyntax286 — a parenthesized with-call in an interface function and a module function
interface ifc;
  int q[$];
  function automatic int f();
    return 5 + (q.sum() with ( item ));
  endfunction
endinterface
module top;
  ifc u ();
endmodule
