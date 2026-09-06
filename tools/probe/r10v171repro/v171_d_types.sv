// r10v171 arm D — RETURN TYPES the law was never decoded on.  The four mint
// sites fire on ANY select or one-name method receiver whose base symbol is
// the subroutine's return value variable, so an unpacked-array, queue,
// dynamic-array, associative-array, struct or class-handle return in a
// wildcard-import CLONE now takes a binding the pass never measured.
package types_home_171;
  typedef int arr3_171 [3];
  typedef struct packed { logic [7:0] hi; logic [7:0] lo; } pk171_t;

  // (T1) UNPACKED ARRAY return, selected.
  function arr3_171 t_arr();
    t_arr[0] = 7;
    t_arr[1] = t_arr[0] + 1;
    t_arr[2] = 9;
  endfunction

  // (T2) QUEUE return: method receiver (push_back / size) + index select.
  function int t_queue_len();
    int qq [$];
    qq.push_back(3);
    t_queue_len = qq.size();
    if (t_queue_len > 0) t_queue_len = t_queue_len - 1;
  endfunction

  // (T3) DYNAMIC ARRAY return: `new[]` receiver, `size()` receiver, select.
  typedef int dyn171_t [];
  function dyn171_t t_dyn();
    t_dyn = new[3];
    t_dyn[0] = 1;
    t_dyn[1] = t_dyn.size();
    t_dyn[2] = 3;
  endfunction

  // (T4) PACKED STRUCT return, part-selected through its own name.
  function pk171_t t_struct();
    t_struct = '{hi: 8'h12, lo: 8'h34};
    t_struct.hi = 8'h56;
  endfunction

  // (T5) ASSOCIATIVE ARRAY return: `exists` receiver + key select.
  typedef int as171_t [string];
  function as171_t t_assoc();
    t_assoc["a"] = 1;
    if (!t_assoc.exists("b")) t_assoc["b"] = 2;
  endfunction

  // (T6) CLASS-HANDLE return: the receiver is a handle, and the method is a
  //      user method, not a built-in.
  class Box171;
    int val;
    function int getv(); return val; endfunction
  endclass
  function Box171 t_handle();
    t_handle = new();
    t_handle.val = 5;
    if (t_handle.getv() != 5) t_handle.val = 0;
  endfunction
endpackage

package types_clone_171;
  import types_home_171::*;
  function int t_use();
    arr3_171 a1;
    dyn171_t d1;
    pk171_t  p1;
    as171_t  s1;
    Box171   b1;
    int      rr;
    a1 = t_arr();
    d1 = t_dyn();
    p1 = t_struct();
    s1 = t_assoc();
    b1 = t_handle();
    rr = a1[0] + t_queue_len() + d1[0] + int'(p1.hi) + s1["a"] + b1.val;
    return rr;
  endfunction
endpackage

module types_top_171;
  import types_clone_171::*;
  int tr;
  initial tr = t_use();
endmodule
