// r10buvm10 arm w1 — THE ENUM-BASE POSITION, one cell per BASE KIND.
// Every `e_*` is an enum whose base is written as the NAME of a package
// typedef; the `p_*` cells are the CONTROLS whose base is not a typedef name
// at all (keyword / vector / implicit), which must stay exactly as they are.
package pk10;
  typedef bit   [7:0] t_bit;
  typedef logic [7:0] t_log;
  typedef int         t_int;
  typedef byte        t_byte;
  typedef shortint    t_sint;
  typedef longint     t_lint;
  typedef integer     t_integer;
  typedef bit   [3:0] t_chain_base;
  typedef t_chain_base t_chain;          // § tdChainNoClone43 cell

  typedef enum t_bit      { B0 = 0, B1 = 1 } e_bit;
  typedef enum t_log      { L0 = 0, L1 = 1 } e_log;
  typedef enum t_int      { I0 = 0, I1 = 1 } e_int;
  typedef enum t_byte     { Y0 = 0, Y1 = 1 } e_byte;
  typedef enum t_sint     { S0 = 0, S1 = 1 } e_sint;
  typedef enum t_lint     { G0 = 0, G1 = 1 } e_lint;
  typedef enum t_integer  { N0 = 0, N1 = 1 } e_integer;
  typedef enum t_chain    { C0 = 0, C1 = 1 } e_chain;
  typedef enum bit  [7:0] { P0 = 0, P1 = 1 } p_vec;
  typedef enum int        { Q0 = 0, Q1 = 1 } p_kw;
  typedef enum            { A0 = 0, A1 = 1 } p_implicit;
endpackage

module top10;
  pk10::e_bit     v1;
  pk10::e_log     v2;
  pk10::e_int     v3;
  pk10::e_chain   v4;
  pk10::p_vec     v5;
  pk10::p_kw      v6;
  pk10::p_implicit v7;
  pk10::e_byte    v8;
  pk10::e_sint    v9;
  pk10::e_lint    v10;
  pk10::e_integer v11;
endmodule
