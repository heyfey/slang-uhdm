// r10sd12 grid cell h3 — THE NEGATIVE CONTROL.  Every element type this law
// must NOT touch, at all four declarator forms, in an in-body method: the
// built-in atoms, a vector, a string, a PACKAGE typedef, an ANONYMOUS in-place
// struct/enum, and a BARE CLASS NAME (not a typedef).  A cell whose element
// classes move here is an OVER-fire and the law is wrong.
package ph3;

  class zcls3;
    int q;
  endclass

  typedef int                       pkg_i3;
  typedef zcls3                     pkg_c3;
  typedef struct packed { int f; }  pkg_s3;
  typedef enum { E0, E1 }           pkg_e3;

  class auser3;
    function void f3();
      int                      v_i[$];
      bit                      v_b[$];
      logic [3:0]              v_l[$];
      string                   v_str[$];
      real                     v_r[$];
      byte                     v_by[4];
      int                      v_ia[string];
      int                      v_id[];
      pkg_i3                   p_i[$];      // a PACKAGE typedef
      pkg_c3                   p_c[$];      // a PACKAGE class typedef
      pkg_s3                   p_s[$];
      pkg_e3                   p_e[4];
      zcls3                    n_cls[$];    // a BARE CLASS NAME, not a typedef
      struct packed { int a; } an_s[$];     // an ANONYMOUS struct
      v_i[0] = 0;
      v_ia["k"] = 1;
    endfunction
  endclass

endpackage

module toph3;
  initial begin
    ph3::auser3 u = new();
    u.f3();
  end
endmodule
