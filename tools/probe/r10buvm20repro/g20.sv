package gp20;
  parameter int PW = 4096;
  typedef logic signed [PW-1:0] bs_t;
  typedef bit [7:0] b8_t;
  typedef int i_t;
  typedef enum {E0, E1} e_t;
  typedef struct packed { logic a; logic b; } s_t;

  // free package function, bare typedef return
  function bs_t free_ret(int size);
    free_ret = 'b0;
  endfunction

  // free package function, qualified typedef return
  function gp20::bs_t free_ret_q(int size);
    free_ret_q = 'b0;
  endfunction

  // free function, other kinds
  function b8_t free_b8(); free_b8 = 0; endfunction
  function i_t  free_i();  free_i = 0;  endfunction
  function e_t  free_e();  free_e = E0; endfunction
  function s_t  free_s();  free_s = '0; endfunction

  class C20;
    // in-body method with bare typedef return
    function bs_t inb_ret(int size);
      inb_ret = 'b0;
    endfunction
    // prototype + OOB definition
    extern virtual function bs_t oob_ret(int size);
    extern function b8_t oob_b8();
    // formals and locals
    function void formals(bs_t f1, gp20::bs_t f2, b8_t f3);
      bs_t l1;
      gp20::bs_t l2;
      b8_t l3;
      l1 = f1; l2 = f2; l3 = f3;
    endfunction
    bs_t prop1;
    gp20::bs_t prop2;
  endclass

  function bs_t C20::oob_ret(int size);
    oob_ret = 'b0;
  endfunction
  function b8_t C20::oob_b8();
    oob_b8 = 0;
  endfunction

  // task with formals
  task tk20(bs_t a, output bs_t b);
    b = a;
  endtask
endpackage

module top20;
  import gp20::*;
  gp20::bs_t w;
  initial w = free_ret(3);
endmodule
