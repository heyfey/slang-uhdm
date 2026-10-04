// § topPkgTdInstanceTop231 — two classes, prototypes and definitions interleaved
package p;
  typedef enum {A0, A1} a_e;
  typedef a_e b_t;
  class c1;
    extern task run(b_t v, int n);
  endclass
  class c2;
    extern function void set(input b_t v);
  endclass
  function void c2::set(input b_t v);
  endfunction
  task c1::run(b_t v, int n);
  endtask
endpackage
module top;
endmodule
