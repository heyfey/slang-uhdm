// § realtimeVarIsTime414
class C;
  realtime t = 2.0;
  static realtime s;
  function realtime get(); return t; endfunction
endclass
module top;
  C c;
endmodule
