// § tfBodyTypedefIsItem304
package p;
  function automatic int g(int a);
    typedef enum {A, B} e_t;
    e_t v;
    v = A;
    return int'(v) + a;
  endfunction
endpackage
module top; endmodule
