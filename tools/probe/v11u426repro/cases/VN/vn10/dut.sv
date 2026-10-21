// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
interface ifc;
  for (genvar g = 0; g < 1; g++) begin : gb
    function integer f;
      box_t r;
      r.a = g;
      f = r.a;
    endfunction
  end
endinterface
module top;
  ifc u();
endmodule
