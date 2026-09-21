// v11u80 q5 -- THE TYPEDEF'd UNPACKED ARRAY (ArrayTdEmpty).  r11u80 writes an
// EMPTY array_var whose fresh array_typespec carries `dt77->getType().name` —
// the DECLARED alias' name.  Under a CHAIN of array typedefs that name is the
// OUTER alias, which is a guess this grid tests; the 2-D and struct-element
// and net-declared spellings are untested too, as is a typedef'd array with a
// declarator dimension on top (the implementer's residue 2) and a typedef'd
// array of a typedef'd array.
package pq5;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;
  typedef logic [7:0] arr_t   [0:1];
  typedef arr_t       arr2_t;              // CHAIN of array typedefs
  typedef arr2_t      arr3_t;              // chain x2
  typedef logic [7:0] arr2d_t [0:1][0:2];  // 2-D typedef'd array
  typedef sl_t        arrs_t  [0:1];       // struct-element typedef'd array
  typedef reg   [7:0] arrr_t  [0:1];       // reg-based typedef'd array
  typedef arr_t       arrn_t  [0:2];       // array OF a typedef'd array

  arr_t   t_a;        // the measured control
  arr2_t  t_a2;       // chain
  arr3_t  t_a3;       // chain x2
  arr2d_t t_2d;       // 2-D
  arrs_t  t_sl;       // struct element
  arrr_t  t_r;        // reg base
  arrn_t  t_nest;     // nested typedef'd array
  arr_t   t_plus [0:2];   // typedef'd array PLUS a declarator dim (residue 2)
  wire    [7:0] t_ctl [0:1];  // the plain control beside them
endpackage

module dut (output logic [31:0] o);
  import pq5::*;
  assign o = {24'd0, t_a[0]} ^ {24'd0, t_a2[0]} ^ {24'd0, t_a3[0]}
           ^ {24'd0, t_2d[0][0]} ^ {16'd0, t_sl[0]} ^ {24'd0, t_r[0]}
           ^ {24'd0, t_nest[0][0]} ^ {24'd0, t_plus[0][0]}
           ^ {24'd0, t_ctl[0]};
endmodule
