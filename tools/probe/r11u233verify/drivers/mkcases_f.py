#!/usr/bin/env python3
"""r11u233: mkcases_f.py: writes cases/F (the forward-package-reference laws of pass 227: § fwdPkgRefClassScopeSpan227 and
§ fwdPkgRefConstSlotWhole227v): every constant-grammar slot a subroutine body or a package holds, the spaced form, three
packages in a chain, a package referenced both forward and backward, classes in the later package, includes and macros."""
import os
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases', 'F')
L = '// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — '
P2 = '''package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
'''
TOP = '''module dut (output int o);
  assign o = p1::X;
endmodule
'''
def w(name, desc, p1body, extra_after='', files=None):
    p = os.path.join(R, name); os.makedirs(p, exist_ok=True)
    open(os.path.join(p, 'dut.sv'), 'w').write(L + desc + '\n' + 'package p1;\n' + p1body + 'endpackage\n' + (extra_after or P2) + TOP)
    for fn, t in (files or {}).items(): open(os.path.join(p, fn), 'w').write(t)
w('f01', 'a localparam inside a function body', '''  function automatic int f();
    localparam int L = p2::K;
    return L + 1;
  endfunction
  localparam int X = f();
''')
w('f02', 'a packed dimension of a function-local variable', '''  function automatic int f();
    logic [p2::K-1:0] v;
    v = '1;
    return int'(v);
  endfunction
  localparam int X = f();
''')
w('f03', "the function's return type range", '''  function automatic logic [p2::K-1:0] f();
    return '1;
  endfunction
  localparam int X = int'(f());
''')
w('f04', 'an enum member value of a typedef inside a function body', '''  function automatic int f();
    typedef enum int {A = p2::K, B} le_t;
    le_t e;
    e = B;
    return int'(e);
  endfunction
  localparam int X = f();
''')
w('f05', 'an unpacked dimension of a function-local array', '''  function automatic int f();
    int arr [p2::K];
    foreach (arr[i]) arr[i] = i;
    return arr[1];
  endfunction
  localparam int X = f();
''')
w('f06', 'a case item expression in a function body', '''  function automatic int f(int a);
    case (a)
      p2::K: return 1;
      default: return 0;
    endcase
  endfunction
  localparam int X = f(4);
''')
w('f07', 'delay controls in a package task: #p2::K (ps_identifier) and #(p2::K)', '''  task automatic t(output int r);
    #p2::K r = 1;
    #(p2::K) r = 2;
  endtask
  localparam int X = 1;
''')
w('f08', 'event controls in a package task: @p2::ev and @(p2::ev)', '''  task automatic t(output int r);
    @p2::ev r = 1;
    @(p2::ev) r = 2;
  endtask
  localparam int X = 1;
''', extra_after=P2.replace('endpackage', '  event ev;\nendpackage'))
w('f09', 'the spaced form p2 :: E1 in a pattern member and in part-select bounds', '''  typedef struct packed { logic [2:0] x; logic [3:0] y; } s_t;
  localparam s_t S = '{x: p2 :: E1, y: p2::W[p2 :: E3:0]};
  localparam int X = int'(S);
''')
w('f10', 'three packages in a chain: p1 reads p2 forward, p2 reads p3 forward', '''  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
  localparam int X = int'(S);
''', extra_after='''package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  typedef struct packed { logic [3:0] z; } t_t;
  localparam t_t T = '{z: p3::M};
endpackage
package p3;
  localparam logic [3:0] M = 4'd9;
endpackage
''')
w('f11', 'a package referenced both forward (by p0) and backward (by p3)', '''  localparam int X = 1;
''', extra_after='''package p0;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S0 = '{x: p2::E2};
endpackage
''' + P2 + '''package p3;
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S3 = '{x: p2::E2};
endpackage
''')
w('f12', 'a class inside the later package, and a class of the earlier package reading it', '''  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
  class A;
    function int g(); return p2::K; endfunction
  endclass
  localparam int X = int'(S);
''', extra_after=P2.replace('endpackage', '  class C; static int K = 3; endclass\nendpackage'))
w('f13', 'the later package in an included file (another file: the law declines)', '''  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
  localparam int X = int'(S);
''', extra_after='`include "p2.svh"\n', files={'p2.svh': P2})
w('f14', 'a macro carrying the reference into a pattern member, part-select bounds and a replication count', '''  `define R p2::E2
  typedef struct packed { logic [2:0] x; logic [2:0] y; logic [1:0][7:0] z; } s_t;
  localparam s_t S = '{x: `R, y: p2::W[`R:0], z: '{`R{8'h1}}};
  localparam int X = int'(S);
''')
w('f15', 'a packed dimension of a type argument of $bits', '''  localparam int X = $bits(logic [p2::K-1:0]) + $bits(logic [p2::K:0][1:0]);
''')
w('f16', 'a streaming slice size in a function body', '''  function automatic logic [7:0] f(logic [7:0] x);
    return {<< p2::K {x}};
  endfunction
  localparam int X = int'(f(8'h1));
''')
w('f17', 'a function default argument', '''  function automatic int f(int a = p2::K);
    return a;
  endfunction
  localparam int X = f();
''')
w('f18', 'package variable initializers (expression grammar outside a subroutine)', '''  int pv = p2::K;
  int pw = p2::K + 1;
  localparam int X = 1;
''')
w('f19', 'a size cast by the forward parameter in a function body', '''  function automatic int f(int x);
    return int'(p2::K'(x));
  endfunction
  localparam int X = f(9);
''')
w('f20', 'loop bounds, repeat and while conditions in a function body', '''  function automatic int f();
    int s = 0;
    for (int i = 0; i < p2::K; i++) s++;
    repeat (p2::K) s++;
    while (s < p2::K * 4) s++;
    return s;
  endfunction
  localparam int X = f();
''')
w('f21', 'nested calls carrying the reference', '''  function automatic int g(int a); return a + 1; endfunction
  function automatic int f(int a); return g(a) * 2; endfunction
  localparam int X = f(g(p2::K));
''')
w('f22', 'part-select bounds, an indexed width and a replication count inside a function body', '''  typedef struct packed { logic [2:0] x; logic [1:0][7:0] z; } s_t;
  function automatic int f();
    logic [7:0] v;
    s_t s;
    v = p2::W[p2::E3:0];
    v = p2::W[0 +: p2::E2];
    s = '{x: 1, z: '{p2::E2{8'h1}}};
    return int'(v) + int'(s);
  endfunction
  localparam int X = f();
''')
w('f23', 'an inside value range and a case-inside item in a function body', '''  function automatic int f(int a);
    if (a inside {[p2::E1:p2::E3]}) return 1;
    case (a) inside
      [p2::K:p2::K+2]: return 2;
      default: return 0;
    endcase
  endfunction
  localparam int X = f(2);
''')
w('f24', 'a typedef of a packed vector inside a function body, and a cast to it', '''  function automatic int f(int x);
    typedef logic [p2::K-1:0] v_t;
    v_t v;
    v = v_t'(x);
    return int'(v);
  endfunction
  localparam int X = f(9);
''')
w('f25', 'a conditional with a condition holding the reference (C && p2::E1 ? a : b) and a pattern member ternary', '''  typedef struct packed { logic [2:0] x; } s_t;
  localparam bit C = 1;
  localparam int Y = C && p2::E1 ? 3 : 4;
  localparam s_t S = '{x: p2::K > 2 ? p2::E1 : p2::E2};
  localparam int X = Y + int'(S);
''')
w('f26', 'dimension bounds of a package typedef and a package localparam packed type (constant grammar outside a subroutine)', '''  typedef logic [p2::K-1:0] v_t;
  localparam logic [p2::K:0] L = '1;
  typedef enum logic [2:0] {A = p2::E1, B} le_t;
  localparam int X = $bits(v_t) + int'(L);
''')

def pat(name, desc, member, wd=8):
    w(name, desc, f'''  typedef struct packed {{ logic [{wd-1}:0] x; }} s_t;
  localparam s_t S = '{{x: {member}}};
  localparam int X = int'(S);
''')
pat('f27', 'a packed dimension of a $bits type argument inside a pattern member', '$bits(logic [p2::K-1:0])')
pat('f28', 'a size cast by the forward parameter inside a pattern member', "p2::K'(5)")
pat('f29', 'an inside value range inside a pattern member', 'p2::W inside {[p2::E1:p2::E3]}')
pat('f30', 'the dimension argument of $size inside a pattern member', "$size(p2::W, p2::E1)")
pat('f31', 'a streaming slice size inside a pattern member', "{<< p2::K {8'hA5}}")
pat('f32', 'a parenthesized reference inside a pattern member', '(p2::E1)')
pat('f33', 'a constant ternary inside a pattern member (both branches forward)', '(1 ? p2::E1 : p2::E2)')
pat('f34', 'a cast to the later package\'s enum type inside a pattern member', "p2::e_t'(1)")
pat('f35', 'a system call with two forward arguments inside a pattern member', '$clog2(p2::K) + $bits(p2::W)')
w('f36', 'a module parameter reading the later package inside a pattern (a module scope: the law declines, control)', '''  localparam int X = 1;
''', extra_after=P2 + '''module m #(parameter p2::e_t P = p2::E1);
endmodule
''')
print('ok')
