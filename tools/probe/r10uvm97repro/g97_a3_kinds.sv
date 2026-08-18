// r10uvm97 arm a3 — NEGATIVE / CONTRAST.  MEASUREMENT-ONLY golden arm.
//
// The non-class typedef kinds inside a class body, and a SPECIALIZATION-target
// typedef, beside the self-referential class-handle one.  A patch that keyed on
// "a typedef named the same in two class bodies" instead of on the DECLARING
// GENERIC CLASS would light this arm up; it must not.
package r97c;

  class holder97c #(type T = int);
    typedef struct packed { logic [3:0] a; logic [3:0] b; } s97c;  // struct
    typedef enum { E0_97C, E1_97C } e97c;                          // enum
    typedef int i97c;                                              // builtin
    typedef logic [7:0] v97c;                                      // vector
    typedef T t97c;                                                // type param
    s97c f_s;  e97c f_e;  i97c f_i;  v97c f_v;  t97c f_t;
  endclass

  class useint97c extends holder97c #(int);
    function void take(i97c x); f_i = x; endfunction
  endclass

  class usebyte97c extends holder97c #(byte);
    function void take(i97c x); f_i = x; endfunction
  endclass

endpackage

module top97c;
endmodule
