// r10v178 VERIFIER ARM F — NAME SHADOWING, BLOCK KINDS, AGGREGATE PARAMETERS.
// MEASUREMENT ONLY.
//  * the IMPORTER declares a parameter with the SAME NAME as the home's, so
//    the clone body's bare name is ambiguous to any name-keyed gate;
//  * a THIRD package declares the same name again;
//  * block kinds the implementer's arms do not walk: named begin, foreach,
//    repeat, do-while, forever+disable, fork/join_none, nested named blocks;
//  * aggregate parameters: an unpacked-array parameter and a struct parameter
//    read from inside a clone.

package Alpha_home_F;
  parameter int SHARED_N = 32'h0a0a_1111;
  parameter int arr_p [0:3] = '{1, 2, 3, 4};
  typedef struct packed { int hi; int lo; } pr_t;
  parameter pr_t st_p = '{hi: 7, lo: 9};

  function automatic int f_named(input int a);
    int r; r = a;
    begin : nm_blk
      r ^= SHARED_N;
    end
    return r;
  endfunction
  function automatic int f_foreach(input int a);
    int r; r = a;
    foreach (arr_p[i]) r = r + arr_p[i] + SHARED_N;
    return r;
  endfunction
  function automatic int f_repeat(input int a);
    int r; r = a;
    repeat (3) r ^= SHARED_N;
    return r;
  endfunction
  function automatic int f_dowhile(input int a);
    int r; r = a;
    do r ^= SHARED_N; while (r < 0);
    return r;
  endfunction
  function automatic int f_nestblk(input int a);
    int r; r = a;
    begin : outer_b
      begin : inner_b
        if (a[0]) r ^= SHARED_N;
      end
    end
    return r;
  endfunction
  function automatic int f_struct(input int a);
    return a + st_p.hi + st_p.lo + SHARED_N;
  endfunction
  function automatic int f_arrsel(input int a);
    int r; r = a; r = r + arr_p[2]; r ^= SHARED_N; return r;
  endfunction
  task automatic t_fork(input int a, output int b);
    b = a;
    fork
      b = b ^ SHARED_N;
    join_none
  endtask
endpackage

// The IMPORTER declares the SAME NAME. Legal: its own declaration hides the
// wildcard-imported one for code WRITTEN here, but the CLONE's body still
// belongs to Alpha_home_F.
package Beta_imp_F;
  import Alpha_home_F::*;
  parameter int SHARED_N = 32'hffff_2222;
  function automatic int g_own(input int a);
    int r; r = a; r ^= SHARED_N; return r;   // Beta's OWN SHARED_N
  endfunction
endpackage

// A third, unrelated declaration of the same name in a package that does NOT
// import anything.
package Gamma_far_F;
  parameter int SHARED_N = 32'h0000_3333;
  function automatic int h_far(input int a);
    int r; r = a; r ^= SHARED_N; return r;
  endfunction
endpackage

module m_v178f (input logic ck, output int f1, f2, f3, f4, f5, f6, f7, f8, f9);
  import Alpha_home_F::*;
  import Beta_imp_F::SHARED_N;
  import Gamma_far_F::h_far;
  int tf1;
  assign f1 = f_named(1);
  assign f2 = f_foreach(2);
  assign f3 = f_repeat(3);
  assign f4 = f_dowhile(4);
  assign f5 = f_nestblk(5);
  assign f6 = f_struct(6);
  assign f7 = f_arrsel(7);
  assign f8 = h_far(8);
  assign f9 = tf1;
  always_comb t_fork(9, tf1);
endmodule
