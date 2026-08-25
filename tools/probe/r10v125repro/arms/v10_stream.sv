// v125 arm V10 — streaming-concatenation lvalue as an output actual, plus a
// concatenation lvalue and a nested call, both converting and matching.
package Str_Pkg;
  typedef logic [63:0] S64;
  function automatic int put(output S64 v); v = 64'd1; return 0; endfunction
  function automatic int eat(input  S64 v); return int'(v); endfunction

  class Str_User;
    int rc;
    logic [31:0] aWord, bWord;
    logic [63:0] wideWord;
    function void go();
      rc = put({>>{aWord, bWord}});   // streaming lvalue, matching total width
      rc = put({aWord, bWord});       // plain concatenation lvalue
      rc = put(wideWord);             // matching control
      rc = eat(put(aWord) ? wideWord : wideWord); // nested call in an operand
      rc = eat({<<8{wideWord}});      // streaming as an INPUT (no lvalue arg)
    endfunction
  endclass
endpackage
