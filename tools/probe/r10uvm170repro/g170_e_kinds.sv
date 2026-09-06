// r10uvm170 arm E — THE TYPE-KIND AXIS inside ONE DPI-exported package
// function, with the non-exported twin beside it.  This is the arm that
// FENCED the law: only a typedef written as an INLINE enum / struct / union
// degrades; every SIMPLE-TYPE alias and every TYPEDEF OF A TYPEDEF resolves,
// INCLUDING `typedef t_enum t_alias_enum;` whose canonical type IS an enum.
package pe170;
  typedef enum bit [1:0] { E0, E1 } t_enum;
  typedef struct packed { bit [3:0] a; } t_struct;
  typedef union  packed { bit [3:0] a; bit [3:0] b; } t_union;
  typedef logic [7:0]      t_vecl;
  typedef bit   [7:0]      t_vecb;
  typedef int              t_int;
  typedef byte             t_byte;
  typedef t_enum           t_alias_enum;
  typedef t_struct         t_alias_struct;
  typedef t_vecl           t_alias_vec;
  typedef logic [3:0][7:0] t_vec2;

  function void snk_e(int q);
  endfunction

  export "DPI-C" function fx_e;
  function void fx_e(int s);
    snk_e(int'(t_enum'(s)));         // x01  -> unsupported
    snk_e(int'(t_struct'(s)));       // x02  -> unsupported
    snk_e(int'(t_union'(s)));        // x03  -> unsupported
    snk_e(int'(t_vecl'(s)));         // x04  -> RESOLVES
    snk_e(int'(t_vecb'(s)));         // x05  -> RESOLVES
    snk_e(int'(t_int'(s)));          // x06  -> RESOLVES
    snk_e(int'(t_byte'(s)));         // x07  -> RESOLVES
    snk_e(int'(t_alias_enum'(s)));   // x08  -> RESOLVES  (the fence's cell)
    snk_e(int'(t_alias_struct'(s))); // x09  -> RESOLVES  (the fence's cell)
    snk_e(int'(t_alias_vec'(s)));    // x10  -> RESOLVES
    snk_e(int'(t_vec2'(s)));         // x11  -> RESOLVES
  endfunction

  function void fy_e(int s);
    snk_e(int'(t_enum'(s)));         // y01
    snk_e(int'(t_struct'(s)));       // y02
    snk_e(int'(t_union'(s)));        // y03
    snk_e(int'(t_vecl'(s)));         // y04
    snk_e(int'(t_vecb'(s)));         // y05
    snk_e(int'(t_int'(s)));          // y06
    snk_e(int'(t_byte'(s)));         // y07
    snk_e(int'(t_alias_enum'(s)));   // y08
    snk_e(int'(t_alias_struct'(s))); // y09
    snk_e(int'(t_alias_vec'(s)));    // y10
    snk_e(int'(t_vec2'(s)));         // y11
  endfunction
endpackage

module top_e170;
  initial pe170::fy_e(1);
endmodule
