// v149b arm -- SCOPES: a struct typedef declared inside a FUNCTION, inside a
// TASK, inside an always block scope, and a virtual/parameterized class.
package Delta9_pkg;
  virtual class VBase #(type T = int);
    typedef struct {
      string vArgs[$];
      T      vPayload;
    } v_rec_t;
    static v_rec_t vHeld;
  endclass

  function automatic int fnScope(int seed);
    typedef struct {
      string fnArgs[$];
      int    fnTag;
    } fn_rec_t;
    fn_rec_t fr;
    fr.fnTag = seed;
    return fr.fnTag;
  endfunction
endpackage

module scoped_top;
  import Delta9_pkg::*;
  int got;
  task automatic tkScope(int seed);
    typedef struct {
      string tkArgs[$];
      int    tkTag;
    } tk_rec_t;
    tk_rec_t tr;
    tr.tkTag = seed;
    got = tr.tkTag;
  endtask
  initial got = fnScope(3);
endmodule
