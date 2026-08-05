// t35b — how far does the type-param alias typespec go?  Separates
//   (a) a PLAIN `typedef int f_int;` in a class (is it listed at all?)
//   (b) type-param aliases whose root default is int / bit / logic[7:0] / a
//       struct / an enum
// so § typedefAliasSharesTypespec25's arm-B emission is grounded on the type
// it must build, not guessed from the one `int` case UVM happens to use.
package pk2;

  typedef struct { int a; int b; } st_t;
  typedef enum { E0, E1 } en_t;

  class P;
    typedef int              f_int;
    typedef bit              f_bit;
    typedef logic [7:0]      f_vec;
    typedef st_t             f_st;
    typedef en_t             f_en;
    int p;
  endclass

  class Q #(type TI = int, type TI2 = TI,
            type TB = bit, type TB2 = TB,
            type TV = logic [7:0], type TV2 = TV,
            type TS = st_t, type TS2 = TS,
            type TE = en_t, type TE2 = TE);
    typedef TI  q_int_a;
    typedef TI2 q_int_b;
    typedef TB  q_bit_a;
    typedef TB2 q_bit_b;
    typedef TV  q_vec_a;
    typedef TV2 q_vec_b;
    typedef TS  q_st_a;
    typedef TS2 q_st_b;
    typedef TE  q_en_a;
    typedef TE2 q_en_b;
    int q;
  endclass

endpackage

module top2;
  import pk2::*;
  P p_h;
  Q #() q_h;
  initial begin
    p_h = new();
    q_h = new();
  end
endmodule
