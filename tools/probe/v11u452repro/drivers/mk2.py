import os
R='/tmp/wt_v11u452/tools/probe/v11u452repro/cases'
C={}
def c(g,n,law,txt): C[(g,n)]=(law,txt)
L='tfLocalClassArrElemClassTs452'
c('VC','vc13',L,'''class C;
  int x;
endclass
module top;
  if (1) begin : g
    task t;
      C arr[2];
    endtask
  end
endmodule''')
c('VC','vc14',L,'''class C;
  int x;
endclass
program prg;
  task t;
    C arr[2];
  endtask
endprogram
module top;
  prg p();
endmodule''')
c('VC','vc15',L,'''class C;
  int x;
endclass
module top;
  function automatic void f();
    C a[2][3];
    C b[0:1];
  endfunction
endmodule''')
c('VC','vc16',L,'''class C;
  int x;
endclass
module sub;
  task t;
    C arr[2];
  endtask
endmodule
module top;
  sub u1();
  sub u2();
endmodule''')
L='thisNetPerListingModule452'
c('VT','vt08',L,'''package u;
  class C;
    int m_a;
    extern function void show();
  endclass
  function void C::show();
    $display("%p", this);
  endfunction
endpackage
package a;
  import u::*;
  class D;
    int m_d;
    extern function void put();
  endclass
  function void D::put();
    $display("%p", this);
  endfunction
endpackage
package b;
  import a::*;
  class E;
    int m_e;
    extern function void get();
  endclass
  function void E::get();
    $display("%p", this);
  endfunction
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import a::*;
endmodule
module m3;
  import b::*;
endmodule
module top;
  m1 x();
  m2 y();
  m3 z();
endmodule''')
c('VT','vt09',L,'''package u;
  class C;
    int m_a;
    extern function void show();
  endclass
  function void C::show();
    $display("%p", this);
  endfunction
endpackage
package a;
  import u::*;
  class D;
    int m_d;
    extern function void put();
  endclass
  function void D::put();
    $display("%p", this);
  endfunction
endpackage
module m1;
  import u::*;
  import a::*;
endmodule
module m2;
  import a::*;
endmodule''')
c('VT','vt10',L,'''package u;
  class C;
    int m_a;
    extern function void show();
    extern function void show2();
  endclass
  function void C::show();
    $display("%p", this);
  endfunction
  function void C::show2();
    $display("%p", this.m_a);
  endfunction
endpackage
package a;
  import u::*;
  class D;
    int m_d;
    extern function void put();
  endclass
  function void D::put();
    $display("%p", this);
  endfunction
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import u::*;
  import a::*;
endmodule''')
L='ifaceConnNetAfterForwarded452'
c('VW','vw03',L,'''package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(bif bus); endmodule
module top;
  import pk::*;
  bif bus();
  slave DUT(.*);
endmodule''')
c('VW','vw05',L,'''package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
interface bif; logic clk; modport mp(input clk); endinterface
module slave(bif.mp bus); endmodule
module top;
  import pk::*;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule''')
L='clsImpEnumTdShare452'
c('VE','ve05',L,'''package a;
  typedef enum {X, Y} st_t;
  st_t g_state;
endpackage
package b;
  import a::*;
  class C;
    int x;
    st_t own;
  endclass
endpackage
module top;
  import b::*;
  C c;
  initial begin
    c = new;
    c.own = X;
  end
endmodule''')
for (g,n),(law,txt) in C.items():
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § '+law+'\n'+txt+'\n')
print(len(C))
