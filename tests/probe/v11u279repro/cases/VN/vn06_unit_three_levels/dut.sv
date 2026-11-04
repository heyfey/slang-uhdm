// § clsTdMemberContainerPath279
class a_c;
  class b_c;
    class c_c;
      typedef struct { int x; } r_t;
    endclass
  endclass
  function void f(); b_c::c_c::r_t v; v.x = 1; endfunction
endclass
module top;
  a_c o;
  initial o = new();
endmodule
