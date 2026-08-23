package pv30e;
  typedef enum { EB0, EB1 } eb_t;
  typedef enum bit signed [3:0] { EQ0 = -1, EQ1 = 2 } eq_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sp_t;
  typedef union packed { logic [7:0] a; sp_t b; } up_t;
  typedef logic signed [7:0] l8_t;
  class cv30e;
    int m;
    extern function eq_t e_enum();
    extern function sp_t e_struct();
    extern function up_t e_union();
    extern function l8_t e_l8();
    extern function byte e_byte();
    extern function shortint e_short();
    extern function longint e_long();
    extern function integer e_integer();
    extern function bit e_bit();
  endclass
  function eq_t cv30e::e_enum();     return eq_t'(-1);        endfunction
  function sp_t cv30e::e_struct();   return sp_t'(-1);        endfunction
  function up_t cv30e::e_union();    return up_t'(-1);        endfunction
  function l8_t cv30e::e_l8();       return (m == -1) ? -2 : -3; endfunction
  function byte cv30e::e_byte();     return -1;               endfunction
  function shortint cv30e::e_short();return (m + -1);         endfunction
  function longint cv30e::e_long();  return (m * -1);         endfunction
  function integer cv30e::e_integer();return (m - -1);        endfunction
  function bit cv30e::e_bit();       return (m == -1);        endfunction
endpackage
