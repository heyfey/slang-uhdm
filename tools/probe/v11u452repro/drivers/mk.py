import os,sys
R='/tmp/wt_v11u452/tools/probe/v11u452repro/cases'
C={}
def c(g,n,law,txt,top=None):
    C[(g,n)]=(law,txt,top)
L='elabAssocVecIdxRange452'
c('VX','vx01',L,'''module top;
  int m[bit[7:0]];
  initial m[3] = 1;
endmodule''')
c('VX','vx02',L,'''module top;
  int m[logic signed [15:0]];
  initial m[-3] = 1;
endmodule''')
c('VX','vx03',L,'''module top;
  int m[reg[3:0]];
  initial m[2] = 5;
endmodule''')
c('VX','vx04',L,'''module top;
  int m[logic[3:0][1:0]];
  initial m[1] = 5;
endmodule''')
c('VX','vx05',L,'''module top;
  int m[logic[0:7]];
  initial m[1] = 5;
endmodule''')
c('VX','vx06',L,'''interface ifc;
  int m[logic[7:0]];
endinterface
module top;
  ifc u();
endmodule''')
c('VX','vx07',L,'''module top;
  for (genvar g = 0; g < 2; g++) begin : gb
    int m[logic[7:0]];
  end
endmodule''')
c('VX','vx08',L,'''package p;
  int m[logic[7:0]];
endpackage
module top;
  import p::*;
  initial m[1] = 2;
endmodule''')
c('VX','vx09',L,'''module top;
  function automatic int f();
    int m[logic[7:0]];
    m[1] = 3;
    return m[1];
  endfunction
  initial $display(f());
endmodule''')
c('VX','vx10',L,'''class C;
  int m[logic[7:0]];
endclass
module top;
  int k[logic[7:0]];
  C c;
endmodule''')
c('VX','vx11',L,'''module top;
  int m[logic[7:0]][3];
  int n[3][logic[7:0]];
endmodule''')
c('VX','vx12',L,'''module top #(parameter W = 8);
  int m[logic[W-1:0]];
  int n[logic[7:0]];
endmodule''')
c('VX','vx13',L,'''module top;
  int m[logic['h7:0]];
  int n[logic[8'd7:0]];
endmodule''')
c('VX','vx14',L,'''module sub;
  int m[logic[15:0]];
  string s[bit[3:0]];
endmodule
module top;
  sub u1();
  sub u2();
endmodule''')
c('VX','vx15',L,'''module top;
  typedef logic [7:0] k_t;
  int m[k_t];
  int n[logic];
  int o[logic[7:0]];
endmodule''')
c('VX','vx16',L,'''module sub;
  int m[logic[31:0]];
endmodule''')
c('VX','vx17',L,'''module top;
  logic [7:0] m[bit signed[7:0]];
  int unsigned q[logic unsigned [3:0]];
endmodule''')
c('VX','vx18',L,'''program prg;
  int m[logic[7:0]];
endprogram
module top;
  prg p();
endmodule''')
L='tfLocalClassArrElemClassTs452'
c('VC','vc01',L,'''class C;
  int x;
endclass
module top;
  task t;
    C arr[4];
    arr[0] = new;
  endtask
endmodule''')
c('VC','vc02',L,'''package p;
  class C;
    int x;
  endclass
  function void f();
    C arr[2];
    arr[0] = new;
  endfunction
endpackage
module top;
  import p::*;
endmodule''')
c('VC','vc03',L,'''package p;
  class P #(int N = 4);
    int x;
  endclass
  class R;
    task body;
      P #(8) a[2];
      P b[2];
    endtask
  endclass
endpackage
module top;
endmodule''')
c('VC','vc04',L,'''package p;
  class C;
    int x;
  endclass
endpackage
package q;
  class R;
    task body;
      p::C a[2];
    endtask
  endclass
endpackage
module top;
endmodule''')
c('VC','vc05',L,'''package p;
  class C;
    int x;
  endclass
  class R;
    function void body();
      C a[2][3];
      C b[0:3];
    endfunction
  endclass
endpackage
module top;
endmodule''')
c('VC','vc06',L,'''package p;
  interface class IC;
    pure virtual function void f();
  endclass
  class R;
    task body;
      IC a[2];
    endtask
  endclass
endpackage
module top;
endmodule''')
c('VC','vc07',L,'''package p;
  typedef class C;
  class R;
    task body;
      C a[2];
    endtask
  endclass
  class C;
    int x;
  endclass
endpackage
module top;
endmodule''')
c('VC','vc08',L,'''package p;
  class C;
    int x;
  endclass
endpackage
module top;
  import p::*;
  function automatic void f();
    C arr[3];
    foreach (arr[i]) arr[i] = new;
  endfunction
endmodule''')
c('VC','vc09',L,'''package p;
  virtual class B;
    int x;
  endclass
  class R;
    static task body;
      B a[2];
      int k[2];
    endtask
  endclass
endpackage
module top;
endmodule''')
c('VC','vc10',L,'''module top;
  class C;
    int x;
  endclass
  class R;
    task body;
      C a[2];
    endtask
  endclass
endmodule''')
c('VC','vc11',L,'''package p;
  class C;
    int x;
  endclass
  class R;
    task body;
      C a[2], b[3];
      C c;
    endtask
  endclass
endpackage
package q;
  import p::*;
  class S extends R;
    int y;
  endclass
endpackage
module top;
  import q::*;
endmodule''')
c('VC','vc12',L,'''interface ifc;
  class C;
    int x;
  endclass
  task t;
    C arr[2];
  endtask
endinterface
module top;
  ifc u();
endmodule''')
L='clsOwnProtoAndOobDefBoth452'
c('VO','vo01',L,'''package q;
  int g;
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function void write(int t);
    extern task run();
  endclass
  function void S::write(int t);
    y = t;
  endfunction
  task S::run();
    y = 2;
  endtask
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo02',L,'''package q;
  function void write(int t);
  endfunction
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo03',L,'''package q;
  class B;
    virtual function void write(int t);
    endfunction
  endclass
endpackage
package r;
  import q::*;
  class S extends B;
    int y;
    extern virtual function void write(int t);
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo04',L,'''package q;
  int g;
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function new();
  endclass
  function S::new();
    y = 1;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo05',L,'''package q;
  int g;
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function void write(int t);
  endclass
  class T;
    int z;
    extern function void read();
  endclass
  function void T::read();
    z = 1;
  endfunction
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo06',L,'''package u;
  int g;
endpackage
package q;
  import u::*;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo07',L,'''package q;
  int g;
endpackage
package r;
  import q::*;
  class S;
    static int y;
    extern static function void write(int t);
    function void inl();
    endfunction
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo08',L,'''package q;
  int g;
endpackage
package r;
  import q::g;
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void S::write(int t);
    y = t + g;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo09',L,'''package q;
  int g;
endpackage
package r;
  import q::*;
  function void free1();
  endfunction
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void free2();
  endfunction
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule''')
c('VO','vo10',L,'''package q;
  int g;
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module a;
  import r::*;
endmodule
module top;
  import r::*;
  a u();
endmodule''')
L='hoistPoolTransitiveImports452'
c('VH','vh01',L,'''package u;
  class E;
    int z;
    extern function void go();
  endclass
  function void E::go();
    z = 1;
  endfunction
endpackage
package q;
  import u::*;
endpackage
package r;
  import q::*;
endpackage
module top;
  import r::*;
  wire w;
endmodule''')
c('VH','vh02',L,'''package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
  class S;
    int y;
  endclass
endpackage
module top;
  import r::S;
  wire w;
endmodule''')
c('VH','vh03',L,'''package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
  class S;
    int y;
  endclass
endpackage
module top import r::*; (input logic a, output logic b);
  assign b = a;
endmodule''')
c('VH','vh04',L,'''package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
  class S;
    int y;
  endclass
endpackage
interface ifc;
  import r::*;
  logic c;
endinterface
module top;
  ifc u();
endmodule''')
c('VH','vh05',L,'''package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
  export q::*;
  class S;
    int y;
  endclass
endpackage
module top;
  import r::*;
  wire w;
endmodule''')
c('VH','vh06',L,'''package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
endpackage
package s;
  import q::*;
endpackage
module top;
  import r::*;
  import s::*;
  wire w;
endmodule''')
c('VH','vh07',L,'''package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
endpackage
module sub;
  import r::*;
endmodule
module top;
  import q::*;
  sub u();
endmodule''')
c('VH','vh08',L,'''package q;
  class D;
    int x;
    extern function void run();
  endclass
  function void D::run();
    x = 1;
  endfunction
endpackage
package r;
  import q::*;
endpackage
module top(input logic a, output logic b);
  import r::*;
  assign b = ~a;
endmodule''')
L='thisNetPerListingModule452'
c('VT','vt01',L,'''package u;
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
  import u::*;
  import a::*;
endpackage
module m2;
  import u::*;
  import b::*;
endmodule
module m1;
  import u::*;
endmodule''')
c('VT','vt02',L,'''package u;
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
    extern task put();
  endclass
  task D::put();
    $display("%p", this.m_d);
  endtask
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import a::*;
endmodule
module m3;
  import a::*;
endmodule''')
c('VT','vt03',L,'''package u;
  class C;
    int m_a;
    extern function new();
  endclass
  function C::new();
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
endmodule
module m2;
  import a::*;
endmodule''')
c('VT','vt04',L,'''package u;
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
endmodule
module m2;
  import a::*;
endmodule
module top;
  m1 x();
  m2 y();
endmodule''')
c('VT','vt05',L,'''package u;
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
endmodule''')
c('VT','vt06',L,'''package u;
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
interface i1;
  import u::*;
endinterface
module m2;
  import a::*;
endmodule
module top;
  i1 x();
  m2 y();
endmodule''')
c('VT','vt07',L,'''package u;
  class C;
    int m_a;
    function void show();
      $display("%p", this);
    endfunction
  endclass
endpackage
package a;
  import u::*;
  class D;
    int m_d;
    function void put();
      $display("%p", this);
    endfunction
  endclass
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import a::*;
endmodule''')
L='thisNetFlatStreamPlace452'
c('VF','vf01',L,'''package pk;
  int p;
  class C;
    int m_z;
    int m_y;
    extern function int get_z();
    extern function void show();
  endclass
  function int C::get_z();
    return m_z + p;
  endfunction
  function void C::show();
    $display("%p", this);
  endfunction
endpackage
module top;
  import pk::*;
endmodule''')
c('VF','vf02',L,'''package pk;
  class C;
    int m_z;
    int m_y;
    extern function new();
    extern function int get_y();
  endclass
  function C::new();
    $display("%p", this);
  endfunction
  function int C::get_y();
    return m_y;
  endfunction
endpackage
module top;
  import pk::*;
endmodule''')
L='ifaceConnNetAfterForwarded452'
c('VW','vw01',L,'''package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  bif B1();
  bif B2();
  slave D1(.bus(B1));
  slave D2(.bus(B2));
endmodule''')
c('VW','vw02',L,'''package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  bif BUS();
  slave DUT(BUS);
endmodule''')
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
module slave(interface bus); endmodule
module top;
  import pk::*;
  bif bus();
  slave DUT(.*);
endmodule''')
c('VW','vw04',L,'''package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  logic x;
  bif BUS();
  wire y;
  slave DUT(.bus(BUS));
  initial $dumpvars(0, top);
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
interface bif; logic clk; endinterface
module slave(bif.mp bus); endmodule
module top;
  import pk::*;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule''')
c('VW','vw06',L,'''package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  bif BUS[2]();
  slave DUT(.bus(BUS[0]));
endmodule''')
c('VW','vw07',L,'''interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule''')
L='clsImpParamOncePerName452'
c('VP','vp01',L,'''package u;
  parameter int P = 1;
endpackage
package v;
  parameter int P = 2;
endpackage
package e1;
  import u::*;
  import v::*;
endpackage
package tp;
  import e1::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import tp::*;
endmodule''')
c('VP','vp02',L,'''package u;
  parameter int P1 = 1;
  localparam int L1 = 3;
endpackage
package a;
  import u::*;
endpackage
package b;
  import u::*;
endpackage
package e1;
  import a::*;
  import b::*;
  import u::*;
endpackage
package tp;
  import e1::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import tp::*;
endmodule''')
c('VP','vp03',L,'''package u;
  parameter int P1 = 1;
endpackage
package a;
  import u::*;
  parameter int P1A = 4;
endpackage
package e1;
  import u::*;
  import a::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import e1::*;
endmodule''')
L='clsImpEnumTdShare452'
c('VE','ve01',L,'''package a;
  typedef enum {X, Y} st_t;
  st_t g_state;
  st_t g_arr[2];
endpackage
package b;
  import a::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import b::*;
endmodule''')
c('VE','ve02',L,'''package a;
  typedef enum bit [1:0] {X, Y} st_t;
  st_t g_state = Y;
endpackage
package b;
  import a::*;
  class C;
    int x;
  endclass
endpackage
package c2;
  import a::*;
  class D;
    int y;
  endclass
endpackage
module top;
  import b::*;
  import c2::*;
endmodule''')
c('VE','ve03',L,'''package u;
  typedef enum {X, Y} st_t;
endpackage
package a;
  import u::*;
  st_t g_state;
endpackage
package b;
  import a::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import b::*;
endmodule''')
c('VE','ve04',L,'''package a;
  enum {X, Y} g_anon;
  typedef enum {P, Q} st_t;
  st_t g_state;
endpackage
package b;
  import a::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import b::*;
endmodule''')
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
  initial begin
    C c = new;
    c.own = X;
  end
endmodule''')
L='clsImpRepTsClassKey452'
c('VK','vk01',L,'''package u;
  class Reg #(type T = int);
    int k;
  endclass
  class Base;
    int b;
  endclass
endpackage
package a;
  import u::*;
  class A extends Base;
    typedef Reg #(A) type_id;
  endclass
endpackage
package b;
  import u::*;
  import a::*;
  class B extends Base;
    typedef Reg #(B) type_id;
  endclass
endpackage
module top;
  import b::*;
endmodule''')
c('VK','vk02',L,'''package u;
  class Cb #(type T = int);
    int k;
  endclass
endpackage
package a;
  import u::*;
  class A;
    typedef Cb #(A) cb_type;
  endclass
endpackage
package b;
  import u::*;
  import a::*;
  class B;
    typedef Cb #(B) cb_type;
    int z;
  endclass
endpackage
module top;
  import b::*;
endmodule''')
for (g,n),(law,txt,top) in C.items():
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § '+law+'\n'+txt+'\n')
    if top: open(os.path.join(d,'TOP'),'w').write(top+'\n')
print(len(C))
