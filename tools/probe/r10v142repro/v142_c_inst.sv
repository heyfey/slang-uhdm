// r10v142 verifier arm C — THREE INSTANCES of the same module, a class-handle
// RETURN type, a $cast target, and a generate-block subroutine.
package pv3142;
  class Kv3142;
    static function Kv3142 mk();
      Kv3142 r = null;
      return r;
    endfunction
  endclass
endpackage

module subv3142 #(parameter int Wv3142 = 1);
  import pv3142::*;
  class Mv3142;
    int f;
  endclass
  Mv3142 mv3142;
  function void mtf3142;
    Mv3142 m_same;
    Kv3142 m_pkg;
  endfunction
  function void mbl3142();
    Mv3142 mb_same;
    Kv3142 mb_pkg;
  endfunction
  function Kv3142 rtf3142;
    Kv3142 r_loc;
    rtf3142 = r_loc;
  endfunction
  function Kv3142 rbl3142();
    Kv3142 rb_loc;
    rbl3142 = rb_loc;
  endfunction
  task tskio3142;
    input int qv3142;
    Mv3142 t_same;
    Kv3142 t_pkg;
  endtask
  task tskbl3142;
    Mv3142 tb_same;
    Kv3142 tb_pkg;
  endtask
  initial begin
    Mv3142 cast_dst;
    $cast(cast_dst, mv3142);
  end
  if (Wv3142 > 0) begin : gblk3142
    function void gtf3142;
      Mv3142 g_same;
      Kv3142 g_pkg;
    endfunction
    function void gbl3142();
      Mv3142 gb_same;
      Kv3142 gb_pkg;
    endfunction
  end
endmodule

module topv3142;
  subv3142 #(.Wv3142(1)) u1v3142 ();
  subv3142 #(.Wv3142(2)) u2v3142 ();
  subv3142 #(.Wv3142(3)) u3v3142 ();
endmodule
