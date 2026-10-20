// § thisCallResultMemberDropped415
typedef struct { int a; int b; } st_t;
class C;
  function st_t mk();
    st_t v;
    v.a = 1; v.b = 2;
    return v;
  endfunction
  function int g();
    return this.mk().b;
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; r = h.g(); end
endmodule
