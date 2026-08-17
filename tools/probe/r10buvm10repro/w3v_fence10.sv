// r10buvm10 arm w3 — THE FENCE ARM.  The same package typedef reached at every
// position LAW S and § arrayElemTdClone42 already own, with NO enum in sight:
// nothing here may move, because the law's only site is the enum BASE.
package pf10;
  typedef bit [7:0] f_t;
  typedef logic [3:0] g_t;
  typedef struct packed { bit [1:0] a; } s_t;
  typedef enum { EA = 0, EB = 1 } n_t;

  parameter f_t FP = 8'h5;
  f_t pkgvar;
  f_t parr [3];
  s_t pkgstruct;
  n_t pkgenum;

  class cf10;
    f_t prop;                                        // class property
    g_t gprop;
    s_t sprop;
    f_t parr2 [2];
    function f_t rf(f_t formal);                     // return type + formal
      f_t loc = formal;                              // body local
      if (loc != 0) begin
        f_t nested = loc;                            // NESTED-block local
        return nested;
      end
      return loc;
    endfunction
  endclass

  function automatic f_t pfun(g_t arg);
    f_t l2 = 0;
    return l2;
  endfunction
endpackage

module mf10 (input pf10::f_t pin, output pf10::f_t pout);
  import pf10::*;
  f_t mv;
  wire g_t mnet;   // f_t is 2-state bit -> not a legal net type
  s_t ms;
  n_t mn;
  parameter f_t MP = 8'h3;
  assign pout = pin;
  assign mnet = mv[3:0];
endmodule
