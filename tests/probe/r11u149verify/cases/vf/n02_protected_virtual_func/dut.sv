// § classMethodQualSpan144
module dut;
  class c;
    protected virtual function int f(input int a);
      return a;
    endfunction
    virtual local function void g();
    endfunction
  endclass
endmodule
