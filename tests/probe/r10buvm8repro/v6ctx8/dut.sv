// CONTEXT matrix: which enclosing shapes must stay BARE.
package cp6;
  typedef logic [7:0] b_t;
  import "DPI-C" context function int dpi6(input int a);
  function int f1 (int a); return dpi6(a); endfunction
  // -- window CONTROL
  function int c_ok (int a);      return f1(a); endfunction
  // -- fences inside the package function body
  function int c_begin (int a);   begin return f1(a); end endfunction
  function int c_if (int a);      if (a) return f1(a); return 0; endfunction
  function int c_for (int a);     for (int i=0;i<2;i++) return f1(a); return 0; endfunction
  function int c_while (int a);   while (a) return f1(a); return 0; endfunction
  function int c_do (int a);      do return f1(a); while (a); endfunction
  function int c_case (int a);    case (a) 0: return f1(a); default: return 0; endcase endfunction
  function int c_assign (int a);  int t; t = f1(a); return t; endfunction
  function int c_twostmt (int a); int t; t = 1; return f1(a); endfunction
  function int c_fork (int a);    int t; fork t = f1(a); join_none return t; endfunction
  // -- a TASK's body (no value return)
  task c_task (int a); int t; t = f1(a); endtask
  // -- class methods
  class C6;
    function int m_in (int a);  return f1(a); endfunction
    extern function int m_oob (int a);
  endclass
  function int C6::m_oob (int a); return f1(a); endfunction
endpackage
module m6;
  import cp6::*;
  int r[12];
  // -- module function: top-level return, reached only from an initial
  function int m_fn (int a); return f1(a); endfunction
  // -- module function reached from a CONT ASSIGN
  function int m_ca (int a); return f1(a); endfunction
  wire logic [31:0] w = m_ca(3);
  cp6::C6 c;
  initial begin
    r[0]=cp6::c_ok(1);   r[1]=cp6::c_begin(1); r[2]=cp6::c_if(1);
    r[3]=cp6::c_for(1);  r[4]=cp6::c_while(0); r[5]=cp6::c_do(0);
    r[6]=cp6::c_case(0); r[11]=cp6::c_fork(1); r[7]=cp6::c_assign(1); r[8]=cp6::c_twostmt(1);
    r[9]=m_fn(1); cp6::c_task(1);
    c = new(); r[10]=c.m_in(1); r[11]=c.m_oob(1);
  end
endmodule
