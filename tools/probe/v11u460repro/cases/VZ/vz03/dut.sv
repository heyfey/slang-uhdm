// § modArrPatBasedLitElemW460 (function-local, generate-scope and interface carriers)
interface ifc;
  int ia[2] = '{'h1, 'h2};
endinterface
module top;
  function int f();
    int fa[2] = '{'h5, 'h6};
    return fa[0];
  endfunction
  for (genvar g = 0; g < 2; g++) begin : gb
    int ga[2] = '{'ha, 'hb};
  end
  ifc i();
  int r;
  initial r = f();
endmodule
