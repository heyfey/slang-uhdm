// r10uvm170 arm D — THE NEGATIVE CONTROL.  Not one `export "DPI-C"` in the
// file, and every cast spelling and site the other three arms use.  NOTHING
// here may move between the pristine and the patched binary.
package fd170;
  typedef enum bit [1:0] { FD0, FD1 } fd_t;
endpackage

typedef enum bit [1:0] { UD0, UD1 } ud_t;

package pd170;
  import fd170::*;
  typedef enum bit [1:0] { D0, D1 } ed_t;
  typedef struct packed { bit [3:0] d; } sd_t;
  typedef logic [7:0] ld_t;

  function void snk_d(int q);
  endfunction

  function ed_t f_d(ed_t io_bare, int s);
    ed_t loc_bare;
    sd_t loc_struct;
    begin
      ed_t blk_bare;
      snk_d(0);
    end
    snk_d(int'(ed_t'(s)));
    snk_d(int'(sd_t'(s)));
    snk_d(int'(ld_t'(s)));
    snk_d(int'(pd170::ed_t'(s)));
    snk_d(int'(fd_t'(s)));
    snk_d(int'(fd170::fd_t'(s)));
    snk_d(int'(byte'(s)));
    snk_d(int'(4'(s)));
    f_d = ed_t'(s);
  endfunction

  task t_d(ed_t io_bare, int s);
    ed_t loc_bare;
    snk_d(int'(ed_t'(s)));
  endtask

  ed_t pkg_var;

  class cd170;
    ed_t prop_bare;
    function void m(int s);
      snk_d(int'(ed_t'(s)));
    endfunction
  endclass
endpackage

module mod_d170;
  typedef enum bit [1:0] { MD0, MD1 } emd_t;
  function void snk_md(int q);
  endfunction
  function void f_md(int s);
    snk_md(int'(emd_t'(s)));
    snk_md(int'(pd170::ed_t'(s)));
    snk_md(int'(ud_t'(s)));
  endfunction
  initial f_md(1);
endmodule

module top_d170;
  mod_d170 u_m();
  initial pd170::t_d(pd170::D0, 1);
endmodule
