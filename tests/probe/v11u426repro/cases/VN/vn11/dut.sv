// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  function integer f;
    int k;
    begin : b
      box_t r;
      r.a = 1;
      k = r.a;
    end
    f = k;
  endfunction
  initial $display(f());
endmodule
