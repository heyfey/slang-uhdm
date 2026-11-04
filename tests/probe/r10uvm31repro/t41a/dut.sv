// t41a — the io_decl TYPESPEC matrix, pass 31's ranked #1.
//
// The r10uvm31pair census split SeqDriver's 1411 differing formals into
//   1197 ts/INST  (golden `@adpcm_pkg` where we say `@uvm_pkg`)
//    128 ts/KIND  (golden `unsupported_typespec 'REQ'` where we resolve the
//                  class type PARAMETER to `class_typespec 'uvm_sequence_item'`)
//     83 ts/NAME  (golden `uvm_pkg::uvm_hdl_data_t` where we say the bare
//                  `uvm_hdl_data_t`; golden `uvm_pkg::uvm_tlm_phase_e` where
//                  we emit an EMPTY name)
// and the same KIND/NAME classes appear on all four UVM-4 tests while the
// INST class appears only on SeqDriver — the only one of the four with a USER
// package that imports uvm_pkg.  This arm is the minimal reproduction of both:
//
//   p31u  = the "library" package (uvm_pkg's role): named typedefs of every
//           kind used as subroutine formals, in a plain class, in an
//           out-of-body definition and at package scope.
//   p31a  = the "user" package (adpcm_pkg's role): imports p31u::* and derives
//           a class from the library's base.  Its presence is what the INST
//           class turns on.
//   param31 = the parameterised class (uvm_sequencer's role): formals typed by
//           a type PARAMETER, by a typedef OF a type parameter, and by a
//           scoped name into another class.
package p31u;
  typedef enum int { S0, S1 } stat_e;
  typedef struct packed { bit [1:0] a; bit [1:0] b; } slice_t;
  typedef logic [7:0] data_t;
  typedef bit [3:0]   nib_t;

  class holder31;
    typedef holder31 h_q_t;
  endclass

  class base31;
    // one formal per named-typedef kind, no direction (so no default either)
    virtual function void take_enum  (input stat_e  s); endfunction
    virtual function void take_struct(input slice_t sl); endfunction
    virtual function void take_data  (input data_t  d); endfunction
    virtual function void take_nib   (input nib_t   n); endfunction
    // an out-of-body definition of the same shapes
    extern virtual function void oob_enum(input stat_e s);
    extern virtual function void oob_data(input data_t d);
  endclass
  function void base31::oob_enum(input stat_e s); endfunction
  function void base31::oob_data(input data_t d); endfunction

  // package-scope subroutines with the same formals
  function void pk_enum(input stat_e s); endfunction
  function void pk_data(input data_t d); endfunction

  // the PARAMETERISED class: type-parameter formals and typedefs of them
  class param31 #(type REQ = base31, type RSP = REQ, type IMP = int,
                  type REQ_IMP = IMP, type RSP_IMP = IMP);
    typedef IMP     this_imp_type;
    typedef REQ_IMP this_req_type;
    typedef RSP_IMP this_rsp_type;
    typedef param31 #(REQ, RSP) this_type;
    // formal typed by the type PARAMETER itself
    virtual function void take_req(input REQ t); endfunction
    virtual function void take_rsp(input RSP t); endfunction
    // formal typed by a TYPEDEF of a type parameter
    virtual function void take_imp(input this_imp_type i,
                                   input this_req_type rq,
                                   input this_rsp_type rs); endfunction
    // formal typed by the class's own self-typedef
    virtual function void take_self(input this_type o); endfunction
    // formal typed by a SCOPED name into another class
    virtual function void take_scoped(input holder31::h_q_t q); endfunction
    // a formal typed by a package typedef, inside the parameterised class
    virtual function void take_penum(input stat_e s); endfunction
  endclass

  // a NON-parameterised class taking the same scoped name, as the control
  class plain31;
    virtual function void take_scoped(input holder31::h_q_t q); endfunction
  endclass
endpackage

// the "user" package: imports the library and derives from it
package p31a;
  import p31u::*;
  class drv31 extends base31;
    // an inherited-shape formal declared in the DERIVED class
    virtual function void own_enum(input stat_e s); endfunction
    virtual function void own_data(input data_t d); endfunction
  endclass
  // a package-scope subroutine in the USER package over a LIBRARY typedef
  function void ua_enum(input stat_e s); endfunction
endpackage

module top31;
  import p31a::*;
  import p31u::*;
  drv31 d;
  param31 #(base31, base31) p;
  plain31 q;
  initial begin
    d = new();
    p = new();
    q = new();
    pk_enum(S0);
    ua_enum(S0);
  end
endmodule
