// v1: typedef KIND axis on the class-OOB-method return site, all package-homed, bare-written.
package vp1;
  parameter int PW = 4096;
  typedef logic signed [PW-1:0] bs_t;    // param-dependent, signed
  typedef logic [7:0]           l8_t;    // fixed range, unsigned
  typedef logic                 l1_t;    // scalar logic, no range
  typedef bit  [PW-1:0]         bb_t;
  typedef byte                  by_t;
  typedef int                   i_t;
  typedef shortint              si_t;
  typedef longint               li_t;
  typedef integer               ig_t;
  typedef time                  tm_t;
  typedef real                  re_t;
  typedef string                st_t;
  typedef enum {E0,E1}          e_t;
  typedef struct packed {logic a; logic b;} s_t;
  typedef union packed {logic [1:0] a; logic [1:0] b;} u_t;
  typedef bs_t                  bs2_t;   // typedef of typedef
  typedef logic [PW-1:0]        bu_t;    // param-dependent, unsigned

  class C1;
    extern function bs_t   r_bs();
    extern function l8_t   r_l8();
    extern function l1_t   r_l1();
    extern function bb_t   r_bb();
    extern function by_t   r_by();
    extern function i_t    r_i();
    extern function si_t   r_si();
    extern function li_t   r_li();
    extern function ig_t   r_ig();
    extern function tm_t   r_tm();
    extern function re_t   r_re();
    extern function st_t   r_st();
    extern function e_t    r_e();
    extern function s_t    r_s();
    extern function u_t    r_u();
    extern function bs2_t  r_bs2();
    extern function bu_t   r_bu();
  endclass

  function bs_t  C1::r_bs();  r_bs  = 'b0; endfunction
  function l8_t  C1::r_l8();  r_l8  = 'b0; endfunction
  function l1_t  C1::r_l1();  r_l1  = 'b0; endfunction
  function bb_t  C1::r_bb();  r_bb  = 'b0; endfunction
  function by_t  C1::r_by();  r_by  = 0;   endfunction
  function i_t   C1::r_i();   r_i   = 0;   endfunction
  function si_t  C1::r_si();  r_si  = 0;   endfunction
  function li_t  C1::r_li();  r_li  = 0;   endfunction
  function ig_t  C1::r_ig();  r_ig  = 0;   endfunction
  function tm_t  C1::r_tm();  r_tm  = 0;   endfunction
  function re_t  C1::r_re();  r_re  = 0.0; endfunction
  function st_t  C1::r_st();  r_st  = "x"; endfunction
  function e_t   C1::r_e();   r_e   = E0;  endfunction
  function s_t   C1::r_s();   r_s   = '0;  endfunction
  function u_t   C1::r_u();   r_u   = '0;  endfunction
  function bs2_t C1::r_bs2(); r_bs2 = 'b0; endfunction
  function bu_t  C1::r_bu();  r_bu  = 'b0; endfunction
endpackage

module vt1;
  import vp1::*;
  vp1::bs_t w;
  vp1::C1 c;
  initial begin c = new(); w = c.r_bs(); end
endmodule
