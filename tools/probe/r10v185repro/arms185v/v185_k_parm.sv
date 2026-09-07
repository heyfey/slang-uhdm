// r10uvm185 VERIFIER arm K — THE PARAMETERIZATION AXIS.
//
// The pass's grid carries `parameter type` as a DECLINED row (arm B), but never
// a return type written through a SPECIALIZED class scope (`cls#(3)::T`), whose
// one written segment slang gives a `ClassName` node rather than an
// `IdentifierName` — the distinction § classTdLocalVarKindFollowsCompileOrder10's
// `oneSeg` term was written for — and never an `extern` prototype inside a
// PARAMETERIZED class.  Two specialisations are instantiated so the elaborated
// view carries both.
package pk185;

  class ak_plain185;                       // sorts BEFORE mk_user185
    typedef enum { AK0, AK1 }     ak_enum;
    typedef struct { int a; }     ak_rec;
    typedef ak_enum               ak_alias;
  endclass

  class ak_gen185 #(int W = 8);
    typedef enum { GK0, GK1 }     gk_enum;
    typedef bit [W-1:0]           gk_vec;
    // an `extern` prototype INSIDE a parameterised class, returning a
    // NON-generic sibling's typedef, scoped both ways round
    extern function ak_plain185::ak_enum k_gen_early();
    extern function ak_plain185::ak_rec  k_gen_early_rec();
  endclass

  class zk_gen185 #(int V = 4);
    typedef enum { ZK0, ZK1 } zk_enum;
  endclass

  // A NON-generic user naming a SPECIALIZED generic's typedef.
  class mk_user185;
    extern function ak_gen185#(8)::gk_enum k_spec_early();
    extern function ak_gen185#(3)::gk_vec  k_spec_early3();
    extern function zk_gen185#(4)::zk_enum k_spec_late();
    extern function ak_plain185::ak_alias  k_plain_alias();
  endclass

  // A class EXTENDING a specialization, naming the inherited typedef bare.
  class ck_der185 extends ak_gen185#(5);
    extern function gk_enum k_inhspec_bare();
  endclass

  function ak_plain185::ak_enum ak_gen185::k_gen_early();      endfunction
  function ak_plain185::ak_rec  ak_gen185::k_gen_early_rec();  endfunction
  function ak_gen185#(8)::gk_enum mk_user185::k_spec_early();  endfunction
  function ak_gen185#(3)::gk_vec  mk_user185::k_spec_early3(); endfunction
  function zk_gen185#(4)::zk_enum mk_user185::k_spec_late();   endfunction
  function ak_plain185::ak_alias  mk_user185::k_plain_alias(); endfunction
  function ak_gen185#(5)::gk_enum ck_der185::k_inhspec_bare(); endfunction

endpackage

module top185k;
  pk185::ak_gen185#(8)  a8;
  pk185::ak_gen185#(3)  a3;
  pk185::mk_user185     mu;
  pk185::ck_der185      cd;
  initial begin a8 = new(); a3 = new(); mu = new(); cd = new(); end
endmodule
