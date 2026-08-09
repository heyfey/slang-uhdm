// t41b — the cells t41a left open.
//
//  (a) NAME QUALIFICATION.  t41a says a vector typedef formal is named
//      UNQUALIFIED (`data_t`) while an enum/struct one is QUALIFIED
//      (`p31u::stat_e`) — but UVM's `uvm_hdl_data_t` (a vector typedef) comes
//      out QUALIFIED as `uvm_pkg::uvm_hdl_data_t` on all four tests.  The one
//      structural difference is its RANGE: `logic [UVM_HDL_MAX_WIDTH-1:0]`,
//      a PARAMETER bound, where t41a's `data_t` is `logic [7:0]`.  Cells here:
//      literal / localparam / parameter / cross-package-parameter bounds.
//  (b) The `unsupported_typespec 'REQ'` family (128 rows on SeqDriver, on all
//      four tests).  t41a's in-class type-parameter formals RESOLVED on both
//      sides; UVM's are all `extern` + OUT-OF-BODY definitions of a
//      PARAMETERISED class (`task uvm_sequencer::get_next_item(output REQ t)`).
//  (c) The `this_rsp_type` LAST-WINS name: three typedefs of three type
//      parameters that all resolve to `int` share ONE typespec named after the
//      LAST.  Ordered controls, plus a non-int group, plus a group with only
//      one member.
//  (d) The INST family: a SECOND importing package, to tell "the LAST package
//      compiled" from "the importing package".
package q31u;
  parameter int QW = 12;
endpackage

package p31v;
  import q31u::*;
  parameter int PW = 8;
  localparam int LW = 6;

  typedef logic [7:0]      lit_t;    // literal bounds
  typedef logic [LW-1:0]   loc_t;    // localparam bounds
  typedef logic [PW-1:0]   par_t;    // parameter bounds
  typedef logic [QW-1:0]   xpar_t;   // cross-package parameter bounds
  typedef enum int { V0, V1 } ven_t;

  // (e) the NAME-QUALIFICATION family (76 rows, all four tests): golden names
  // `uvm_hdl_deposit`'s formal `uvm_pkg::uvm_hdl_data_t` where we say the bare
  // `uvm_hdl_data_t` — and every one of those subroutines is a DPI IMPORT.
  import "DPI-C" context function int d_lit(string path, lit_t value);
  import "DPI-C" context function int d_ven(string path, ven_t value);
  import "DPI-C" context function int d_out(string path, output lit_t value);
  function int p_lit(input string path, input lit_t value); return 0;
  endfunction

  function void v_lit (input lit_t  a); endfunction
  function void v_loc (input loc_t  a); endfunction
  function void v_par (input par_t  a); endfunction
  function void v_xpar(input xpar_t a); endfunction

  class vc31;
    virtual function void c_lit (input lit_t  a); endfunction
    virtual function void c_loc (input loc_t  a); endfunction
    virtual function void c_par (input par_t  a); endfunction
    virtual function void c_xpar(input xpar_t a); endfunction
  endclass

  // (b) the UVM `uvm_sequencer` shape: a parameterised class whose methods are
  // EXTERN and defined OUT OF BODY.
  class seq31 #(type REQ = ven_t, type RSP = REQ);
    extern virtual function void e_req(input REQ t);
    extern virtual function void e_rsp(input RSP t);
    // and the same two IN BODY, as the control
    virtual function void i_req(input REQ t); endfunction
    virtual function void i_rsp(input RSP t); endfunction
  endclass
  function void seq31::e_req(input REQ t); endfunction
  function void seq31::e_rsp(input RSP t); endfunction

  // a parameterised class over a CLASS default, extern-defined
  class base31; int z; endclass
  class seqc31 #(type REQ = base31, type RSP = REQ);
    extern virtual function void e_creq(input REQ t);
  endclass
  function void seqc31::e_creq(input REQ t); endfunction

  // the CONTROLS the unsupported_typespec law needs: which written spelling
  // in an out-of-body definition of a parameterised class's method is left
  // unsupported, and does the class have to be parameterised at all.
  class seqx31 #(type REQ = ven_t);
    typedef REQ this_r_t;
    extern virtual function void e_concrete(input lit_t a);   // concrete type
    extern virtual function void e_tdparam (input this_r_t t);// typedef of REQ
    extern virtual function void e_mixed   (input lit_t a, input REQ t);
    extern virtual function REQ  e_ret     (input int k);     // RETURN type
    extern virtual function void e_deflt   (input REQ t = null);
  endclass
  function void seqx31::e_concrete(input lit_t a); endfunction
  function void seqx31::e_tdparam (input this_r_t t); endfunction
  function void seqx31::e_mixed   (input lit_t a, input REQ t); endfunction
  function seqx31::REQ seqx31::e_ret(input int k); endfunction
  function void seqx31::e_deflt   (input REQ t = null); endfunction

  // a NON-parameterised class, same extern/out-of-body shape (the control)
  class plainx31;
    extern virtual function void e_plain(input ven_t a);
    extern virtual function void e_plit (input lit_t a);
  endclass
  function void plainx31::e_plain(input ven_t a); endfunction
  function void plainx31::e_plit (input lit_t a); endfunction

  // PURE VIRTUAL prototypes in a parameterised class — UVM's
  // `uvm_structure_proxy#(type STRUCTURE)::get_immediate_children(STRUCTURE s)`
  // and `uvm_visitor#(type NODE)::visit(NODE node)` are exactly this shape and
  // golden gives them `unsupported_typespec` with NO vpiInstance.
  virtual class pv31 #(type PT = base31, type PE = ven_t);
    pure virtual function void pv_cls (PT s);
    pure virtual function void pv_enum(PE e);
    pure virtual function void pv_conc(lit_t a);
  endclass
  // ...and the NON-parameterised pure-virtual control
  virtual class pvp31;
    pure virtual function void pv_plain(ven_t a);
  endclass

  // a VALUE-parameterised class (no type parameter at all)
  class vparam31 #(int W = 8);
    extern virtual function void e_w(input logic [W-1:0] a);
  endclass
  function void vparam31::e_w(input logic [W-1:0] a); endfunction

  // (c) LAST-WINS: three int-resolving typedefs of type parameters, one
  //     non-int group and a single-member group, all in one class.
  class imp31 #(type IMP = int, type REQ_IMP = IMP, type RSP_IMP = IMP,
                type SB = shortint, type OB = base31);
    typedef IMP     this_imp_type;
    typedef REQ_IMP this_req_type;
    typedef RSP_IMP this_rsp_type;
    typedef SB      this_sb_type;    // a group of ONE (shortint)
    typedef OB      this_ob_type;    // a group of ONE (class)
    virtual function void t_imp(input this_imp_type i,
                                input this_req_type rq,
                                input this_rsp_type rs,
                                input this_sb_type  sb,
                                input this_ob_type  ob); endfunction
    // the SAME three types written as the PARAMETERS, not the typedefs
    virtual function void t_par(input IMP i, input REQ_IMP rq,
                                input RSP_IMP rs); endfunction
  endclass
endpackage

// (d) TWO importers of p31v.  If the elaborated-view instance is "the LAST
// package", both importers' formals land on the same one; if it is "the
// importing package", each importer keeps its own.
package p31a;
  import p31v::*;
  function void a_lit(input lit_t a); endfunction
  function void a_ven(input ven_t a); endfunction
endpackage

package p31b;
  import p31v::*;
  function void b_lit(input lit_t a); endfunction
  function void b_ven(input ven_t a); endfunction
endpackage

module top31b;
  import p31a::*;
  import p31b::*;
  import p31v::*;
  vc31 c;
  seq31 #(ven_t, ven_t) s;
  imp31 #() im;
  initial begin
    c = new();
    s = new();
    im = new();
    v_lit(8'h1); v_loc(6'h1); v_par(8'h1); v_xpar(12'h1);
    a_lit(8'h1); b_lit(8'h1);
    a_ven(V0);   b_ven(V0);
  end
endmodule
