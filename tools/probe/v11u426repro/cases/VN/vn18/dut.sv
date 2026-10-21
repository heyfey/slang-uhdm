// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  function integer f;
    box_t r;
    integer i;
    for (i = 0; i < 2; i++) r.a = i;
    f = r.a;
  endfunction
  task t;
    output int o;
    box_t q;
    q.a = 4;
    o = q.a;
  endtask
  initial begin int z; t(z); $display(f(), z); end
endmodule
