// r10uvm152 arm A — WHERE a subroutine block-item local LIVES, by subroutine
// kind and header shape, in a PACKAGE.  Golden decides; nothing here is a judge.
package pa152;

  class Ka152;
    int qa;
  endclass

  class Ha152;
    int zz;
    extern function new();
    extern function void oobm();
    extern task oobt();
    function void ibm();
      Ka152 v_ibm;
      v_ibm = null;
      zz = 1;
    endfunction
    function new_alike();
      Ka152 v_ibnew;
      v_ibnew = null;
      zz = 2;
    endfunction
  endclass

  class Ga152;
    int gz;
    function new();
      Ka152 v_ibctor;
      v_ibctor = null;
      gz = 3;
    endfunction
  endclass

  class Ja152;
    int jz;
    extern function new;
  endclass

  function Ha152::new();
    Ka152 v_ooctor;
    v_ooctor = null;
    zz = 4;
  endfunction

  function Ja152::new;
    Ka152 v_ooctorbare;
    v_ooctorbare = null;
    jz = 5;
  endfunction

  function void Ha152::oobm();
    Ka152 v_oobm;
    v_oobm = null;
    zz = 6;
  endfunction

  task Ha152::oobt();
    Ka152 v_oobt;
    v_oobt = null;
  endtask

  function void pf152();
    Ka152 v_pf;
    v_pf = null;
  endfunction

  Ka152 v_pkgown;

endpackage

module ma152;
  import pa152::*;
  initial begin
    Ha152 h;
    h = new();
  end
endmodule
