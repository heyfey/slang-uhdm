// r10v161 ARM C — THE OVER-BIND HUNT.  Every referent an in-body class method
// can name that golden leaves BARE, read from an ASSERTION CONDITION and from
// a CASE ITEM expression, beside the same read from an `if` CONDITION.  If
// clearing `classMethodNoBind` over-binds anything, it shows here as an
// AWAY-GOLDEN cell.  MEASUREMENT ONLY.  LHS golden, RHS ours.
package pk_c161;
  int pkg_var_c = 3;
  parameter int PK_C = 7;
  typedef enum bit [1:0] {EC0, EC1, EC2} ec_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } st_c;
endpackage

class Held_c161;
  int f = 5;
  static int sf = 6;
  function int m(); return f; endfunction
endclass

class Base_c161;
  int inh_prop = 1;
  static int inh_static = 2;
  virtual function int vm(); return inh_prop; endfunction
endclass

interface if_c161; logic x; endinterface

class Over_c161 extends Base_c161;
  int prop = 1;
  static int sprop = 2;
  const int cprop = 3;
  Held_c161 hprop;
  chandle chprop;
  int aprop[4];
  int qprop[$];
  int assoc[string];
  pk_c161::ec_t eprop;
  pk_c161::st_c stprop;
  localparam int LP_C = 9;
  parameter int PARM_C = 4;

  function int helper(int z); return z; endfunction

  function void c_props(int formal_c);
    int loc = 1;
    // ---- the `if` column: the control our emitter is already right on ----
    if (prop == 1) loc = 1;                              // c01 property
    if (sprop == 2) loc = 1;                             // c02 static property
    if (cprop == 3) loc = 1;                             // c03 const property
    if (inh_prop == 1) loc = 1;                          // c04 inherited property
    if (inh_static == 2) loc = 1;                        // c05 inherited static
    if (hprop != null) loc = 1;                          // c06 class-handle property
    if (aprop[0] == 0) loc = 1;                          // c07 property array element
    if (qprop.size() == 0) loc = 1;                      // c08 queue method call
    if (eprop == pk_c161::EC0) loc = 1;                  // c09 enum property + enum const
    if (LP_C == 9) loc = 1;                              // c10 class localparam
    if (PARM_C == 4) loc = 1;                            // c11 class parameter
    if (pk_c161::PK_C == 7) loc = 1;                     // c12 package parameter
    if (pk_c161::pkg_var_c == 3) loc = 1;                // c13 package variable
    if (this.prop == 1) loc = 1;                         // c14 this.<prop>
    if (super.inh_prop == 1) loc = 1;                    // c15 super.<prop>
    if (Held_c161::sf == 6) loc = 1;                     // c16 C::static
    if (chprop == null) loc = 1;                         // c17 chandle property
    if (stprop.a == 0) loc = 1;                          // c18 struct member of a property
    if (assoc.size() == 0) loc = 1;                      // c19 assoc-array method
    if (helper(loc) == 1) loc = 1;                       // c20 own method call + local arg
    if (vm() == 1) loc = 1;                              // c21 virtual method call
    if ($bits(loc) == 32) loc = 1;                       // c22 $bits(<local>)
    if (loc == 1) loc = 1;                               // c23 plain local
    if (formal_c == 1) loc = 1;                          // c24 formal

    // ---- the ASSERT column: must be cell-for-cell the same as golden ----
    assert (prop == 1);                                  // c31
    assert (sprop == 2);                                 // c32
    assert (cprop == 3);                                 // c33
    assert (inh_prop == 1);                              // c34
    assert (inh_static == 2);                            // c35
    assert (hprop != null);                              // c36
    assert (aprop[0] == 0);                              // c37
    assert (qprop.size() == 0);                          // c38
    assert (eprop == pk_c161::EC0);                      // c39
    assert (LP_C == 9);                                  // c40
    assert (PARM_C == 4);                                // c41
    assert (pk_c161::PK_C == 7);                         // c42
    assert (pk_c161::pkg_var_c == 3);                    // c43
    assert (this.prop == 1);                             // c44
    assert (super.inh_prop == 1);                        // c45
    assert (Held_c161::sf == 6);                         // c46
    assert (chprop == null);                             // c47
    assert (stprop.a == 0);                              // c48
    assert (assoc.size() == 0);                          // c49
    assert (helper(loc) == 1);                           // c50
    assert (vm() == 1);                                  // c51
    assert ($bits(loc) == 32);                           // c52
    assert (loc == 1);                                   // c53
    assert (formal_c == 1);                              // c54
    assert (hprop.f == 5);                               // c55 property.field
    assert (hprop.m() == 5);                             // c56 property method call
  endfunction

  // ---- the CASE ITEM column ------------------------------------------
  function void c_items(int formal_i);
    int loc = 1;
    case (formal_i)
      loc:                loc = 1;                       // c60 local
      formal_i:           loc = 2;                       // c61 formal
      prop:               loc = 3;                       // c62 property
      sprop:              loc = 4;                       // c63 static property
      cprop:              loc = 5;                       // c64 const property
      inh_prop:           loc = 6;                       // c65 inherited property
      LP_C:               loc = 7;                       // c66 class localparam
      pk_c161::PK_C:      loc = 8;                       // c67 package parameter
      pk_c161::pkg_var_c: loc = 9;                       // c68 package variable
      int'(pk_c161::EC1): loc = 10;                      // c69 enum constant
      aprop[0]:           loc = 11;                      // c70 property array element
      loc + 1:            loc = 12;                      // c71 an OPERATION on a local
      helper(loc):        loc = 13;                      // c72 a call with a local arg
      default:            loc = 0;
    endcase
    casex (formal_i)
      loc:      loc = 1;                                 // c73 casex item, local
      prop:     loc = 2;                                 // c74 casex item, property
      default:  loc = 0;
    endcase
    casez (formal_i)
      loc:      loc = 1;                                 // c75 casez item, local
      default:  loc = 0;
    endcase
    case (formal_i) inside
      loc:      loc = 1;                                 // c76 `case inside` item, local
      prop:     loc = 2;                                 // c77 `case inside` item, property
      default:  loc = 0;
    endcase
    case (loc)
      1: begin
           assert (loc == 1);                            // c78 assert in a case-item CLAUSE
         end
      default: loc = 0;
    endcase
  endfunction

  // ---- depth and position controls that must NOT move -----------------
  function void c_depth();
    int loc = 1;
    if (prop > 0) assert (loc == 1);                     // c80 one control body deeper
    while (prop > 0) assert (loc == 1);                  // c81 while body
    for (int k = 0; k < 2; k++) assert (loc == 1);       // c82 for body
    forever begin assert (loc == 1); break; end          // c83 forever body
    repeat (2) assert (loc == 1);                        // c84 repeat body
    do assert (loc == 1); while (prop > 0);              // c85 do-while body
    assert (loc == 1) loc = loc; else loc = loc;         // c86 cond, c87 pass, c88 else
    fork assert (loc == 1); join_none                    // c89 fork arm, d0
    begin assert (loc == 1); end                         // c90 plain begin, d0
    begin : nb assert (loc == 1); end                    // c91 named begin, d0
  endfunction

  // ---- expression shapes inside an assertion condition ----------------
  function void c_shapes(int formal_s);
    int loc = 1;
    Held_c161 h;
    assert (int'(loc) == 1);                             // c92 a CAST of a local
    assert (int'(formal_s) == 1);                        // c93 a CAST of a formal
    assert ($sformatf("%0d", loc) != "");                // c94 sys-call arg
    assert (h == null || h.f == 5);                      // c95 short-circuit
    assert (loc inside {1, 2, 3});                       // c96 inside operator
    assert ((loc > 0) ? (loc == 1) : (prop == 1));       // c97 ternary
    assert (aprop[loc] == 0);                            // c98 local as an INDEX
    assert (qprop[loc] == 0);                            // c99 local indexing a queue
  endfunction
endclass

class GenC161 #(type T = int, int W = 1);
  T gp;
  static int gs = 0;
  function void c_gen(T formal_g);
    T loc;
    assert (gs == 0);                                    // c100 static prop, generic
    assert (W != 0);                                     // c101 type parameter
    assert (formal_g != gp);                             // c102 formal + property
    assert (loc != gp);                                  // c103 local + property
  endfunction
endclass

module top_c161;
  Over_c161 oc;
  GenC161 #(int, 1) gc1;
  GenC161 #(bit, 2) gc2;
  GenC161 #() gc0;
  int mv = 1;
  if_c161 ifc();

  function automatic int mod_fn_c(int q);
    int loc = 1;
    assert (loc == 1);                                   // c110 module function local
    assert (q == 1);                                     // c111 its formal
    assert (mv == 1);                                    // c112 a module variable
    return q;
  endfunction

  initial begin
    int loc = 1;
    assert (loc == 1);                                   // c113 initial-block local
    assert (mv == 1);                                    // c114 a module variable
    oc = new();
    mv = mod_fn_c(1);
  end

  always_comb begin
    assert (mv == 1);                                    // c115 in always_comb
  end
endmodule
