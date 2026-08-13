// r10uvm68 arm a2 — the ATOM grid at SUBROUTINE scope: is the rule the same for
// every predefined integer atom, or only for `int`?  Written vs typedef'd.
typedef int      ai_t;
typedef integer  ag_t;
typedef shortint as_t;
typedef longint  al_t;
typedef byte     ab_t;
typedef time     at_t;
typedef int unsigned aiu_t;
typedef byte unsigned abu_t;

class C2;
  function void f();
    int          p_int;      ai_t   t_int;
    integer      p_intg;     ag_t   t_intg;
    shortint     p_shrt;     as_t   t_shrt;
    longint      p_long;     al_t   t_long;
    byte         p_byte;     ab_t   t_byte;
    time         p_time;     at_t   t_time;
    int unsigned p_uint;     aiu_t  t_uint;
    byte unsigned p_ubyte;   abu_t  t_ubyte;
    p_int = t_int; p_intg = t_intg; p_shrt = t_shrt; p_long = t_long;
    p_byte = t_byte; p_time = t_time; p_uint = t_uint; p_ubyte = t_ubyte;
  endfunction
  function ai_t   r_int();   r_int   = 0; endfunction
  function ag_t   r_intg();  r_intg  = 0; endfunction
  function as_t   r_shrt();  r_shrt  = 0; endfunction
  function al_t   r_long();  r_long  = 0; endfunction
  function ab_t   r_byte();  r_byte  = 0; endfunction
  function at_t   r_time();  r_time  = 0; endfunction
  function aiu_t  r_uint();  r_uint  = 0; endfunction
endclass
module m2_mod; C2 c2; initial c2 = new(); endmodule
