// § timeModVarIsNet406
module top;
  task automatic tk;
    time l;
    l = 1;
  endtask
  function int f;
    static time s;
    return 1;
  endfunction
endmodule
