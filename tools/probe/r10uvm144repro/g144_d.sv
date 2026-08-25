// r10uvm144 arm D — SHAPE x ELEMENT-KIND x HOME grid for the argument of a
// CLASS-SCOPE-QUALIFIED call, plus the fences that must NOT move.
package p144d;

  typedef enum { E0, E1 } e144_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s144_t;

  class K144 #(type T = int);
    T tv;
  endclass

  class E144;
    int ev;
  endclass
  typedef E144 ealias144_t;

  class B144;
    extern static function void qcls (ref E144        a[$]);
    extern static function void qtd  (ref ealias144_t a[$]);
    extern static function void qspec(ref K144#(int)  a[$]);
    extern static function void qint (ref int         a[$]);
    extern static function void qstr (ref string      a[$]);
    extern static function void qstc (ref s144_t      a[$]);
    extern static function void qenm (ref e144_t      a[$]);
    extern static function void dyn  (ref int         a[]);
    extern static function void fixd (ref int         a[3]);
    extern static function void asso (ref int         a[string]);
    extern static function void scal (ref int         a);
    extern static function void hcls (ref E144        a);
    extern static task          tqi  (ref int         a[$]);
  endclass

  function void B144::qcls (ref E144        a[$]); endfunction
  function void B144::qtd  (ref ealias144_t a[$]); endfunction
  function void B144::qspec(ref K144#(int)  a[$]); endfunction
  function void B144::qint (ref int         a[$]); endfunction
  function void B144::qstr (ref string      a[$]); endfunction
  function void B144::qstc (ref s144_t      a[$]); endfunction
  function void B144::qenm (ref e144_t      a[$]); endfunction
  function void B144::dyn  (ref int         a[]);  endfunction
  function void B144::fixd (ref int         a[3]); endfunction
  function void B144::asso (ref int         a[string]); endfunction
  function void B144::scal (ref int         a);    endfunction
  function void B144::hcls (ref E144        a);    endfunction
  task          B144::tqi  (ref int         a[$]); endtask

  class S144;
    int w;
    E144 prop;                                  // class property (must stay bare)

    // ---- SHAPES / ELEMENT KINDS, all at function top, statement position ----
    function void d01(); E144        v[$]; B144::qcls (v); w = 1;  endfunction
    function void d02(); ealias144_t v[$]; B144::qtd  (v); w = 2;  endfunction
    function void d03(); K144#(int)  v[$]; B144::qspec(v); w = 3;  endfunction
    function void d04(); int         v[$]; B144::qint (v); w = 4;  endfunction
    function void d05(); string      v[$]; B144::qstr (v); w = 5;  endfunction
    function void d06(); s144_t      v[$]; B144::qstc (v); w = 6;  endfunction
    function void d07(); e144_t      v[$]; B144::qenm (v); w = 7;  endfunction
    function void d08(); int         v[];  B144::dyn  (v); w = 8;  endfunction
    function void d09(); int         v[3]; B144::fixd (v); w = 9;  endfunction
    function void d10(); int         v[string]; B144::asso(v); w = 10; endfunction
    function void d11(); int         v;    B144::scal (v); w = 11; endfunction
    function void d12(); E144        v;    B144::hcls (v); w = 12; endfunction

    // ---- HOMES ----
    // d20 after statements
    function void d20(); int v[$]; w = 20; B144::qint(v); endfunction
    // d21 inside an explicit begin-end
    function void d21(); begin int v[$]; B144::qint(v); w = 21; end endfunction
    // d22 inside a fork arm
    task d22(); fork begin int v[$]; B144::qint(v); end join_none w = 22; endtask
    // d23 a TASK body
    task d23(); int v[$]; B144::tqi(v); w = 23; endtask
    // d24 a void function (already the default) with THREE instances
    function void d24(); int v1[$]; int v2[$]; int v3[$];
      B144::qint(v1); B144::qint(v2); B144::qint(v3); w = 24; endfunction
    // d25 a STATIC class method
    static function void d25(); int v[$]; B144::qint(v); endfunction
    // d26 the CONSTRUCTOR (§ ctorBodyLocalsNotOnFunc71 must stay)
    function new(); int v[$]; B144::qint(v); endfunction
    // d27 the qualifier+lifetime STUB (§ qualLifetimeStubListsNoBodyLocals141
    //     must stay: no name, no io_decls, no body, no variables)
    local function automatic void d27(); int v[$]; B144::qint(v); endfunction
    // d28 a VIRTUAL method
    virtual function void d28(); int v[$]; B144::qint(v); w = 28; endfunction

    // ---- FENCES: these must NOT move ----
    // d40 class PROPERTY as the argument
    function void d40(); B144::hcls(prop); w = 40; endfunction
    // d41 a SYSTEM call wrapping the scoped call
    function void d41(); int v; $display("%0d", v); w = 41; endfunction
    // d42 `this.` receiver call
    function void d42(); int v; this.sink144(v); w = 42; endfunction
    // d43 a receiver-qualified call in EXPRESSION position
    function void d43(); int v; E144 h; h = null; w = (h == null) ? v : 43; endfunction
    // d44 a call whose qualifier is a TYPEDEF of the own class (§32: degrades)
    function void d44(); int v[$]; alias144_t::qint(v); w = 44; endfunction
    function void sink144(int x); endfunction
  endclass

  typedef B144 alias144_t;

  // out-of-body caller control
  class T144;
    int w;
    extern function void t01();
  endclass
  function void T144::t01(); int v[$]; B144::qint(v); w = 1; endfunction

endpackage
