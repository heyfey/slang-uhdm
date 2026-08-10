// t46a — pass 34's four io_decl formal shapes, each with its control.
//
// (A) a package typedef whose target is a CONTAINER of a class, used as a
//     formal: `typedef uvm_port_component_base uvm_port_list[string];` /
//     `get_connected_to(ref uvm_port_list list)`.  Golden binds the package
//     typedef LISTING object (`class_typespec 'uvm_pkg::uvm_port_list'
//     @uvm_pkg`), we resolve through the alias and name the ELEMENT class.
//     20 rows.  § tdListingFormalAsWritten33 one container over.
// (B) a formal whose WRITTEN type name does not resolve in the class's own
//     scope: a SCOPED name into another class
//     (`uvm_resource_types::rsrc_q_t`, 21 rows) and a type parameter of the
//     BASE class (`STRUCTURE`/`NODE` on uvm_component_proxy /
//     uvm_component_name_check_visitor, 12 rows).  Golden degrades both to an
//     `unsupported_typespec` NAMED AS WRITTEN with NO instance.
// (C) a PURE VIRTUAL prototype's formal and its io_decl RANGES: golden gives
//     `pure virtual function void get_id_set(output string q[$])` the same
//     [0:$] range a defined method's formal carries; § pureVirtIoDecls30
//     emitted the io_decl but never its Ranges.  16 rows (4 on every test).
// (D) `this_type` — pass 33's ranked #1, 58 rows.  Cells only; not modelled.
//
// One IMPORTER (pass 33: a three-importer arm MASKS a one-importer bug).

package p46;

  class el46;
    int z;
  endclass
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st46_t;

  // ---- (A) container typedefs, one per container kind ------------------
  typedef el46   amap46_t[string];   // associative of CLASS  <- uvm_port_list
  typedef el46   aq46_t[$];          // queue of CLASS
  typedef el46   ad46_t[];           // dynamic of CLASS
  typedef el46   af46_t[4];          // fixed unpacked of CLASS
  typedef st46_t smap46_t[string];   // associative of STRUCT
  typedef int    imap46_t[string];   // associative of INT
  typedef el46   acls46_t;           // the plain class ALIAS (pass 33 (b))

  // ---- (B) a class used as a NAMESPACE for typedefs ---------------------
  class ns46;
    typedef el46 nsq46_t;
    typedef int  nsi46_t;
  endclass

  // ---- (B) a generic base whose TYPE PARAMETER a DERIVED class writes ---
  virtual class base46 #(type NODE46 = int);
    pure virtual function void pb_node(NODE46 n);
    virtual function void vb_node(NODE46 n); endfunction
    virtual function void vb_nq(ref NODE46 q[$]); endfunction
  endclass

  class der46 extends base46 #(el46);
    // the formal written as the BASE's type parameter — NOT in der46's scope
    virtual function void pb_node(NODE46 n); endfunction
    virtual function void d_node(NODE46 n); endfunction
    virtual function void d_nq(ref NODE46 q[$]); endfunction
    // ...and the control, the same type written directly
    virtual function void d_cls(el46 n); endfunction
  endclass

  // ...and the same shape where the base's parameter resolves to a BUILTIN,
  // the cell that says whether the degradation is about the SPELLING or
  // about the resolved type.
  virtual class basei46 #(type IP46 = int);
    virtual function void bi_node(IP46 n); endfunction
  endclass
  class deri46 extends basei46 #(int);
    virtual function void di_node(IP46 n); endfunction
    virtual function void di_ctl(int n); endfunction
  endclass

  // more class-scoped typedefs, for the SCOPED-name cells
  class nsx46;
    typedef st46_t nss46_t;      // a packed STRUCT
    typedef el46   nsc46_t[string];  // an ASSOCIATIVE of class
    typedef enum int { NX0, NX1 } nse46_t;   // an ENUM
    typedef logic [7:0] nsv46_t;             // a VECTOR
    typedef string      nst46_t;             // a STRING
    // packed vs UNPACKED struct, both declared HERE (uvm_resource_types'
    // `access_t` is an unpacked struct and golden RESOLVES it)
    typedef struct packed { logic [3:0] a; logic [3:0] b; } nsp46_t;
    typedef struct { int a; time b; }                       nsu46_t;
    typedef el46 nsl46_t[$];                 // a QUEUE of class
    typedef int  nsm46_t[string];            // an ASSOCIATIVE of BUILTIN
    typedef int  nsn46_t[4];                 // a fixed UNPACKED of builtin
  endclass

  // ---- (A)+(B) the formals, in an ordinary class ------------------------
  class use46;
    // (A) each container typedef as a formal
    virtual function void a_map(ref amap46_t m); endfunction
    virtual function void a_q  (ref aq46_t   m); endfunction
    virtual function void a_d  (ref ad46_t   m); endfunction
    virtual function void a_f  (ref af46_t   m); endfunction
    virtual function void a_sm (ref smap46_t m); endfunction
    virtual function void a_im (ref imap46_t m); endfunction
    virtual function void a_cls(acls46_t     m); endfunction
    // ...and the controls, written out
    virtual function void c_map(ref el46 m[string]); endfunction
    virtual function void c_q  (ref el46 m[$]); endfunction
    virtual function void c_cls(el46 m); endfunction
    // (B) the SCOPED name into another class
    virtual function void b_scq(ns46::nsq46_t q); endfunction
    virtual function void b_sci(ns46::nsi46_t q); endfunction
    virtual function void b_scs(nsx46::nss46_t q); endfunction
    virtual function void b_scc(ref nsx46::nsc46_t q); endfunction
    virtual function void b_sce(nsx46::nse46_t q); endfunction
    virtual function void b_scv(nsx46::nsv46_t q); endfunction
    virtual function void b_sct(nsx46::nst46_t q); endfunction
    virtual function void b_scp(nsx46::nsp46_t q); endfunction
    virtual function void b_scu(nsx46::nsu46_t q); endfunction
    virtual function void b_scl(ref nsx46::nsl46_t q); endfunction
    virtual function void b_scm(ref nsx46::nsm46_t q); endfunction
    virtual function void b_scn(ref nsx46::nsn46_t q); endfunction
    // (B) the same typedef reached WITHOUT the scope, from inside ns46's
    // own scope, is the control — see ns46use46 below.
  endclass

  class ns46use46 extends ns46;
    virtual function void e_scq(nsq46_t q); endfunction
  endclass

  // ---- (C) pure virtual prototypes and their DEFINED controls -----------
  virtual class pv46;
    pure virtual function void p_q  (ref el46 q[$]);
    pure virtual function void p_str(output string q[$]);
    pure virtual function void p_unp(ref int u[4]);
    pure virtual function void p_dyn(ref int d[]);
    pure virtual function void p_asc(ref int a[string]);
    pure virtual function void p_qq (ref int qq[$][$]);
    pure virtual function void p_pln(int k);
    // the DEFINED controls, same formals
    virtual function void n_q  (ref el46 q[$]); endfunction
    virtual function void n_str(output string q[$]); endfunction
    virtual function void n_unp(ref int u[4]); endfunction
    virtual function void n_dyn(ref int d[]); endfunction
    virtual function void n_asc(ref int a[string]); endfunction
    virtual function void n_qq (ref int qq[$][$]); endfunction
    virtual function void n_pln(int k); endfunction
  endclass

  // ---- (D) this_type ----------------------------------------------------
  class self46 #(type T46 = int);
    typedef self46 #(T46) this_type;
    // the class that DECLARES this_type
    virtual function void s_this(this_type p); endfunction
  endclass

  class sub46 #(type T46 = int) extends self46 #(T46);
    // ...and a derived class that only INHERITS it
    virtual function void t_this(this_type p); endfunction
  endclass

  class other46;
    typedef other46 this_type;
    virtual function void o_this(this_type p); endfunction
  endclass

endpackage

// exactly ONE importer
package q46;
  import p46::*;
  class q46use;
    virtual function void qa_map(ref amap46_t m); endfunction
    virtual function void qb_scq(ns46::nsq46_t q); endfunction
    // a scoped name into a PACKAGE — the control that says the degradation
    // is about a CLASS scope, not about the `::` spelling.
    virtual function void qc_pkg(p46::acls46_t m); endfunction
    virtual function void qd_pkg(ref p46::amap46_t m); endfunction
  endclass
endpackage

module top46a;
  import p46::*;
  import q46::*;
  use46 u;
  der46 d;
  self46 #() s;
  sub46 #() b;
  other46 o;
  q46use qu;
  initial begin
    u = new();
    d = new();
    s = new();
    b = new();
    o = new();
    qu = new();
  end
endmodule
