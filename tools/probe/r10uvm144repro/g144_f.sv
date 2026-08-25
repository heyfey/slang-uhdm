// r10uvm144 arm F — the QUALIFIER-SPELLING grid (§ classScopeCallWritten-
// QualifierIsLookupKey32) and the PACKAGE-qualified free-function shape the
// corpus already gets right.  Nothing here may move except where golden says.
package q144f;
  function automatic int  pjoin(ref string i[$]); return 0; endfunction
  function automatic void pvoid(ref int    i[$]); endfunction
endpackage

package p144f;
  import q144f::*;

  class Base144;
    extern static function void bv(ref int a[$]);
  endclass
  function void Base144::bv(ref int a[$]); endfunction

  class Der144 extends Base144;
    extern static function void dv(ref int a[$]);
    typedef Der144 this_type144;
  endclass
  function void Der144::dv(ref int a[$]); endfunction

  typedef Der144 alias144;

  class InBody144;
    static function void iv(ref int a[$]); endfunction   // IN-BODY: never registers `InBody144::iv`
  endclass

  class Use144;
    int w;
    string sq[$];
    // f01 the DEFINING class written -> func_call, argument in the window
    function void f01(); int v[$]; Der144::dv(v); w = 1; endfunction
    // f02 a TYPEDEF of the own class -> DEGRADES to a bare ref_obj, no args
    function void f02(); int v[$]; alias144::dv(v); w = 2; endfunction
    // f03 the class's own `this_type` typedef -> DEGRADES
    function void f03(); int v[$]; Der144::this_type144::dv(v); w = 3; endfunction
    // f04 the DERIVED class written for a BASE method -> DEGRADES
    function void f04(); int v[$]; Der144::bv(v); w = 4; endfunction
    // f05 the BASE class written for its own method -> func_call
    function void f05(); int v[$]; Base144::bv(v); w = 5; endfunction
    // f06 an IN-BODY static method -> DEGRADES (never registered under `::`)
    function void f06(); int v[$]; InBody144::iv(v); w = 6; endfunction
    // f07 a PACKAGE-qualified FREE function, STATEMENT position
    function void f07(); int v[$]; q144f::pvoid(v); w = 7; endfunction
    // f08 a PACKAGE-qualified FREE function nested in ANOTHER call's arguments
    //     (the corpus's `uvm_report_info(..., uvm_pkg::m_uvm_string_queue_join(qs), ...)`)
    function void f08(); int r; r = sink144(q144f::pjoin(sq)); w = 8; endfunction
    // f09 the same, assignment RHS directly
    function void f09(); int r; r = q144f::pjoin(sq); w = 9; endfunction
    function int sink144(int x); return x; endfunction
  endclass

endpackage
