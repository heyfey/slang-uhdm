import os
R='/tmp/wt_v11u477/tools/probe/v11u477repro/cases'
def w(g,n,t):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(t)
L1='// § parenCallWrittenArgs477\n'
w('VP','vp19',L1+'''class inner;
  function int m(int a, int b = 7); return a + b; endfunction
endclass
class outer;
  inner h;
  function new(); h = new; endfunction
endclass
module top(output int z);
  outer o;
  initial begin o = new; z = (o.h.m(1)); end
endmodule
''')
w('VP','vp20',L1+'''module top(output string s);
  initial s = ($sformatf("%0d%0d", , 3));
endmodule
''')
w('VP','vp21',L1+'''module top(output int z);
  function automatic int f(int a, int b, int c = 9); return a - b + c; endfunction
  initial z = (f(.b(2), .a(1)));
endmodule
''')
w('VP','vp22',L1+'''interface ifc;
  function automatic int f(int a, int b = 5); return a + b; endfunction
endinterface
module top(output int z);
  ifc u();
  initial z = (u.f(1));
endmodule
''')
w('VP','vp23',L1+'''class c;
  rand int x;
  function void go();
    if ((randomize())) $display("ok");
    if ((this.randomize(x))) $display("ok");
  endfunction
endclass
module top;
endmodule
''')
w('VP','vp24',L1+'''module top(output int z);
  function automatic int f(int a, int b = 5); return a + b; endfunction
  localparam int L = (f(1));
  assign z = L;
endmodule
''')
w('VP','vp25',L1+'''module top(input int a, output int z);
  function automatic int f(int x, int y = 2); return x * y; endfunction
  assign z = (f(a)) ? (f(.x(a))) : (f(a, 3));
endmodule
''')
w('VP','vp26',L1+'''class base;
  virtual function int m(int a, int b = 7); return a + b; endfunction
endclass
class d extends base;
  function int m(int a, int b = 9);
    return (super.m(a));
  endfunction
endclass
module top;
endmodule
''')
