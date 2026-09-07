// r10uvm193 ARM C — THE ARGUMENT-FACE AXIS of
// § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden, both views.  LHS is ALWAYS
// golden.
//
// The producer's argument gate is a single `any_cast<ref_obj*>(arg)` plus an
// `override` test (`the argument's actual is NULL, or carries the ARGUMENT'S
// OWN NAME`).  Sixteen of the corpus's twenty-six array-receiver calls are
// left alone by exactly that gate — `args[i].substr(1,len-1)` and
// `fields[i].get_access(rw.local_map)` write a `constant`, an `operation` and
// a `hier_path` where a name would have to be.  This arm writes every
// argument face beside a direct name so the gate is a measured column.
//
// It also carries the DECLARING-SCOPE axis for the argument itself: golden's
// mint replaces whatever the argument's own declaration was, so a formal, a
// block local, a foreach index, a class property, a package variable and the
// subroutine's own return name all belong here.

package Pier193;

  int pkgcask193;

  class Fender193;
    int m_girth193;
    function new(); m_girth193 = 1; endfunction
    function int rub193(input int cleat193);
      return cleat193 + m_girth193;
    endfunction
    extern function int c9_prop193(input int fml_i193);
  endclass

  // C1  a direct name that is a FUNCTION-LEVEL LOCAL.
  function automatic int c1_local193(input int fml_a193);
    int tackle193[int];
    int kink193;
    kink193 = 1;
    tackle193[kink193] = 1;
    if (tackle193.exists(kink193)) fml_a193 = fml_a193 + 1;
    return fml_a193;
  endfunction

  // C2  a direct name that is a FORMAL.
  function automatic int c2_formal193(input int kink193);
    int tackle193[int];
    tackle193[kink193] = 2;
    if (tackle193.exists(kink193)) kink193 = kink193 + 1;
    return kink193;
  endfunction

  // C3  a CONSTANT argument — refused by `any_cast<ref_obj*>`.
  function automatic int c3_const193(input int fml_c193);
    int tackle193[int];
    tackle193[3] = 3;
    if (tackle193.exists(3)) fml_c193 = fml_c193 + 1;
    return fml_c193;
  endfunction

  // C4  an OPERATION argument — refused.
  function automatic int c4_oper193(input int fml_d193);
    int tackle193[int];
    int kink193;
    kink193 = 4;
    tackle193[kink193] = 4;
    if (tackle193.exists(kink193 + 1)) fml_d193 = fml_d193 + 1;
    return fml_d193;
  endfunction

  // C5  a DOTTED (hier_path) argument — refused; the corpus's
  //     `fields[i].get_access(rw.local_map)` face.
  function automatic int c5_dotted193(input int fml_e193);
    int       tackle193[int];
    Fender193 pad193;
    pad193 = new();
    tackle193[1] = 5;
    if (tackle193.exists(pad193.m_girth193)) fml_e193 = fml_e193 + 1;
    return fml_e193;
  endfunction

  // C6  a SELECTED argument (`bit_select`) — IS-A `ref_obj`, so the producer
  //     does reach it; what golden does with it is the measurement.
  function automatic int c6_select193(input int fml_f193);
    int tackle193[int];
    int shelf193[4];
    tackle193[1] = 6;
    shelf193[0] = 1;
    if (tackle193.exists(shelf193[0])) fml_f193 = fml_f193 + 1;
    return fml_f193;
  endfunction

  // C7  TWO direct names in one call, at argument 0 and argument 1 — the
  //     corpus's `get_address(0,this)` face without the constant.
  function automatic int c7_two193(input int fml_g193);
    Fender193 fleet193[$];
    Fender193 one193;
    int       kink193;
    one193 = new();
    fleet193.push_back(one193);
    kink193 = 0;
    return fml_g193 + fleet193[kink193].rub193(kink193);
  endfunction

  // C8  a BLOCK-LOCAL and a FOREACH INDEX as the argument.
  function automatic int c8_block193(input int fml_h193);
    int tackle193[int];
    int shelf193[3];
    tackle193[0] = 8;
    shelf193[0] = 0;
    foreach (shelf193[ix193]) begin
      int nbl193;
      nbl193 = ix193;
      if (tackle193.exists(ix193))  fml_h193 = fml_h193 + 1;
      if (tackle193.exists(nbl193)) fml_h193 = fml_h193 + 1;
    end
    return fml_h193;
  endfunction

  // C9  a CLASS PROPERTY and a PACKAGE VARIABLE as the argument, in an
  //     out-of-body method whose ARRAY is a subroutine local (so the receiver
  //     itself is in scope and only the argument's declaring scope varies).
  function int Fender193::c9_prop193(input int fml_i193);
    int tackle193[int];
    tackle193[0] = 9;
    if (tackle193.exists(m_girth193)) fml_i193 = fml_i193 + 1;
    if (tackle193.exists(pkgcask193)) fml_i193 = fml_i193 + 1;
    return fml_i193;
  endfunction

  // C10 the subroutine's OWN RETURN NAME as the argument, in a FREE function.
  //     § retNameArgKeepsReturnVar184v is the law that owns this spelling on
  //     § 184's half; this arm records what the ARRAY half does with it.
  function automatic int c10_retname193(input int fml_j193);
    int tackle193[int];
    tackle193[0] = 10;
    c10_retname193 = 1;
    if (tackle193.exists(c10_retname193)) c10_retname193 = 2;
    return c10_retname193 + fml_j193;
  endfunction

  // C11 an argument already bound to a DIFFERENT-NAMED object cannot exist for
  //     a direct name, so the `override` test is exercised the other way: the
  //     SAME name written twice in one call, which is what `pushVar` in the
  //     producer makes visible to the second one.
  function automatic int c11_twice193(input int fml_k193);
    Fender193 fleet193[$];
    Fender193 one193;
    int       kink193;
    one193 = new();
    fleet193.push_back(one193);
    kink193 = 0;
    return fml_k193 + fleet193[kink193].rub193(kink193) + kink193;
  endfunction

endpackage

package Jetty193;
  import Pier193::*;
  function automatic int warp193(input int fml_l193);
    return fml_l193;
  endfunction
endpackage

module top193c;
  import Pier193::*;
  int r193;
  initial begin
    r193 = c1_local193(1) + c2_formal193(2) + c3_const193(3) + c4_oper193(4)
         + c5_dotted193(5) + c6_select193(6) + c7_two193(7) + c8_block193(8)
         + c10_retname193(10) + c11_twice193(11) + Jetty193::warp193(12);
  end
endmodule
