// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  if (1) begin : g
    function integer test;
      box_t r;
      test = r.a;
    endfunction
  end
endmodule
