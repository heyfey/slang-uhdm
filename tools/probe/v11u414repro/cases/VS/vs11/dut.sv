// § structMemberDefault414
module top;
  typedef struct { int a = 3; } s_t;
  function automatic int f();
    s_t l;
    return l.a;
  endfunction
endmodule
