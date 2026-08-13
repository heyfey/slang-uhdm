// r10uvm68 arm a6 — THE FENCE CONTROL.  A typedef'd signed ATOM used as an
// ARRAY element at SUBROUTINE / BLOCK / PACKAGE scope is the exact shape
// § atomVarSignedWritten68 must NOT reach: the objects there belong to
// § arrayVarSignedWritten8 (the array_var) and § arrayElemTsSignedParented9
// (the element typespec), which measured them and set their own rules.
// This arm's job is to be IDENTICAL before and after the patch.  A single cell
// moving here means the gate leaked into makeReturnVar's ELEMENT-REG callers.
typedef int ai6_t;
typedef ai6_t arr3_t[3];
package p6;
  typedef int pi6_t;
  pi6_t pkg_arr[3];          // package array of a typedef'd atom
endpackage

class C6;
  ai6_t cprop_arr[3];        // class property array (r10oth8/9 own this)
  function void f();
    ai6_t l_fix[3];          // function local, FIXED
    ai6_t l_dyn[];           //             ... DYNAMIC
    ai6_t l_que[$];          //             ... QUEUE
    ai6_t l_asc[string];     //             ... ASSOCIATIVE
    int   w_fix[3];          // the WRITTEN twin of each, as the positive control
    int   w_dyn[];
    int   w_que[$];
    int   w_asc[string];
    l_fix[0] = w_fix[0];
    l_dyn = new[2]; w_dyn = new[2];
    l_que.push_back(1); w_que.push_back(1);
    l_asc["a"] = 1; w_asc["a"] = 1;
  endfunction
  // An unpacked-array RETURN, which SystemVerilog can only spell through an
  // ARRAY typedef -- i.e. § arrayVarSignedWritten8's clause-(a) shape exactly.
  function arr3_t r_arr(); r_arr[0] = 0; endfunction
endclass

module m6_mod;
  C6 c6;
  initial begin
    ai6_t b_fix[3];          // BLOCK-item array local
    int   bw_fix[3];
    c6 = new();
    b_fix[0] = bw_fix[0];
  end
endmodule
