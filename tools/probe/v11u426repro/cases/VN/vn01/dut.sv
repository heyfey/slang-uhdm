// § namedTypeLocalTfItemOutsideClass426
module top #(type T = int) ();
  function integer f;
    T x;
    x = 3;
    f = x;
  endfunction
  initial $display(f());
endmodule
