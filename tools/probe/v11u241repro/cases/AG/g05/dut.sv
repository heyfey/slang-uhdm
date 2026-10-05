// § cloneAggTsAtHomeListing241
package p;
  typedef struct { int a; } s_t;
  task automatic t1(input s_t x, output s_t y);
    y = x;
  endtask
  task automatic t2(ref s_t z);
    z.a = 1;
  endtask
  function automatic s_t mk();
    s_t r;
    r.a = 3;
    return r;
  endfunction
endpackage
package q1;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
module top;
  import p::*;
  s_t v;
  initial begin t1(mk(), v); t2(v); end
endmodule
