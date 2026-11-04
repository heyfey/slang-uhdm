// § hpFnStaticTrailScopeJoin246
module top;
  function int mf(); static int sv; sv++; return sv; endfunction
  function void usev(int v); endfunction
  int q;
  initial begin
    usev(mf.sv);
    q = mf.sv + 1;
  end
  class mc;
    function int g(); return mf.sv; endfunction
  endclass
endmodule
