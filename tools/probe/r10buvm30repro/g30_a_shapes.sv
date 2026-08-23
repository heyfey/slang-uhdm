package p30b;
  parameter int PP = 5;
  typedef enum int { E0 = 3 } e_t;

  class c30b;
    int  m;
    int  arr [];
    localparam int LP = 7;
    extern function int f_all(int a);
  endclass

  function int c30b::f_all(int a);
    int q;
    real z;
    q = -1;              // 14 plain
    q = -'d1;            // 15 based decimal
    q = -1'b1;           // 16 sized based
    q = -(1);            // 17 parenthesized literal
    q = - 1;             // 18 space
    q = -PP;             // 19 package param
    q = -LP;             // 20 class localparam
    q = -E0;             // 21 enum const
    q = -64'd1;          // 22 wide based
    q = -'h1;            // 23 hex
    z = -1.0;            // 24 real
    q = -(-1);           // 25 minus of parenthesized minus
    q = -(-1);           // 26 minus of parenthesized minus (duplicate shape; `- -1` is a slang parse error)
    q = -a;              // 27 NON-literal control
    q = -(a+1);          // 28 non-literal control
    q = -m;              // 29 class property control
    q = ~1;              // 30 unary tilde control
    q = !1;              // 31 unary not control
    q = +1;              // 32 unary plus control
    q = &1;              // 33 reduction and
    q = arr[-1];         // 34 array index
    q = {-1, 1};         // 35 concatenation
    q = (a ? -1 : 1);    // 36 ternary arm
    q = $signed(-1);     // 37 call argument
    if (a == -1) q = 0;  // 38 comparison in if
    case (a) -1: q = 0; default: q = 1; endcase   // 39 case item
    return -1;           // 40 return
  endfunction
endpackage
