// § memberInitReducedRootFolds228 — a function-local variable of the member width (untyped root)
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 9};
   localparam int N = Info.x;
   function automatic int f();
      logic [N-1:0] t;
      t = '1;
      return int'(t);
   endfunction
   assign o = f();
endmodule
