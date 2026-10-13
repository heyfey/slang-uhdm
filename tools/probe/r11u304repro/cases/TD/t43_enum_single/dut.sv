// § tfBodyTypedefForcesBegin304
package p;
  int q;
  function automatic void g(int a);
    typedef enum {A, B} e_t;
    q = a;
  endfunction
endpackage
module top; endmodule
