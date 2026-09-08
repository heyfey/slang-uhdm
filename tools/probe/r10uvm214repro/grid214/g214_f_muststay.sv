// r10uvm214 grid arm F — THE MUST-STAY CONTROL.  Everything in a def-view
// clone body that is NOT a package-parameter reference: a class parameter, a
// subroutine formal, a body local, an enum member, a localparam declared inside
// the subroutine, and a class-scope constant.  None of them may move, in either
// view.
package pg214;

  parameter int ka214 = 6;

  typedef enum int { KE214_A = 1, KE214_B = 2 } ke214_e;

  function automatic int ksink214(int a, int b);
    return a + b;
  endfunction

  class K214 #(int KP214 = 4);
    const int kc214 = 8;
    extern function int k_mix214(int arg214);
  endclass

  function int K214::k_mix214(int arg214);
    localparam int kl214 = 12;   // subroutine-scope localparam
    int loc214;
    loc214 = arg214 + kl214;
    loc214 = loc214 + KP214;     // class type/value parameter
    loc214 = loc214 + kc214;     // class-scope constant
    loc214 = loc214 + KE214_A;   // enum member
    loc214 = loc214 + ka214;     // the ONE package-parameter cell (positive
                                 // control: this one is the law's)
    return ksink214(loc214, arg214);
  endfunction

endpackage

module topf214;
  pg214::K214 #(4) k = new();
  int x;
  initial x = k.k_mix214(3);
endmodule
