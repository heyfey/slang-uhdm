// § namedTypeLocalTfItemOutsideClass426
interface ifc;
  typedef struct { int a; } box_t;
  function integer test;
    box_t r;
    test = r.a;
  endfunction
endinterface
module top;
  ifc u();
endmodule
