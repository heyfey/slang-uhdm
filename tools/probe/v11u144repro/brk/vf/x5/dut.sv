// § classMethodQualSpan144
module top;
  class K;
    static task st(); endtask
    local task lt(); endtask
    virtual function void vf(); endfunction
    protected virtual function int pv(); return 0; endfunction
  endclass
endmodule
