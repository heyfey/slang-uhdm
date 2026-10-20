// § realtimeVarIsTime414
module top();
  function realtime f(realtime x);
    realtime y = 2.0;
    return x + y;
  endfunction
  realtime r = f(1.0);
endmodule
