// vbuvm13 arm a2 — SITE + DIRECTION matrix.  Axes v1/v2 do not carry: formal
// DIRECTIONS (output / inout / ref / const ref) with a default naming an earlier
// formal; a DPI-C import prototype; a PARAMETERIZED class (two specialisations);
// a STATIC method; a VIRTUAL (non-pure) method; a class that EXTENDS another; a
// NESTED class; an out-of-body CONSTRUCTOR; a module TASK; an interface TASK.
package pa2;
  int gv2 = 1;
  function int r2(int x); return x; endfunction

  // ---- DIRECTIONS, package free function -------------------------------
  function automatic int d_out  (input int a, output int b, int c = a);        b = a; return a+c; endfunction
  function automatic int d_inout(input int a, inout  int b, int c = a);        return a+c; endfunction
  function automatic int d_ref  (input int a, ref    int b, int c = a);        return a+c; endfunction
  function automatic int d_cref (input int a, const ref int b, int c = a);     return a+c; endfunction
  function automatic int d_defout(input int a, output int b = a);              b = a; return a; endfunction
  function automatic int d_definout(input int a, inout int b = a);             return a; endfunction

  // ---- DPI-C import prototype ------------------------------------------
  import "DPI-C" function int dpi_f(input int a, input int b);
  import "DPI-C" context function int dpi_g(input int a);

  // ---- PARAMETERIZED class, TWO specialisations ------------------------
  class pc2 #(int N = 1);
    localparam int LN = N;
    function int p_earlier(int a, int b = a);       return a+b; endfunction
    function int p_param  (int v = LN);             return v; endfunction
    extern function int p_x(int a, int b = a);
    static function int p_stat(int a, int b = a);   return a+b; endfunction
    virtual function int p_virt(int a, int b = a);  return a+b; endfunction
  endclass
  function int pc2::p_x(int a, int b = a);          return a+b; endfunction

  // ---- EXTENDS + NESTED + out-of-body CONSTRUCTOR ----------------------
  class base2;
    int q;
    function new(int a, int b = a);  q = a+b; endfunction
    virtual function int v_earlier(int a, int b = a); return a+b; endfunction
  endclass
  class der2 extends base2;
    extern function new(int a, int b = a);
    function int dm_earlier(int a, int b = a);      return a+b; endfunction
    virtual function int v_earlier(int a, int b = a); return a+b+1; endfunction
    class nest2;
      function int n_earlier(int a, int b = a);     return a+b; endfunction
      function int n_call   (int a, int b = r2(a)); return a+b; endfunction
    endclass
  endclass
  function der2::new(int a, int b = a); super.new(a); endfunction
endpackage

interface ifa2;
  function automatic int i_earlier(int a, int b = a); return a+b; endfunction
  task automatic i_task(input int a, input int b = a); endtask
  function automatic int i_call(int a, int b = pa2::r2(a)); return a+b; endfunction
endinterface

module m_a2;
  import pa2::*;
  ifa2 u_if();
  int z, w;
  pc2 #(1) h1;
  pc2 #(2) h2;
  der2 hd;
  function automatic int mm_earlier(int a, int b = a); return a+b; endfunction
  function automatic int mm_call   (int a, int b = r2(a)); return a+b; endfunction
  task automatic mm_task(input int a, input int b = a); endtask
  initial begin
    z = d_out(1, w);   z = d_inout(1, w);  z = d_ref(1, w);  z = d_cref(1, w);
    z = d_defout(1);   z = d_definout(1);
    z = dpi_f(1, 2);   z = dpi_g(1);
    h1 = new(); h2 = new(); hd = new(1);
    z = h1.p_earlier(1); z = h1.p_param(); z = h1.p_x(1);
    z = pc2#(1)::p_stat(1); z = h1.p_virt(1);
    z = hd.dm_earlier(1); z = hd.v_earlier(1);
    z = u_if.i_earlier(1); u_if.i_task(1); z = u_if.i_call(1);
    z = mm_earlier(1); z = mm_call(1); mm_task(1);
  end
endmodule
