// vb32r2 — RISK ARM F2b: the written qualifier is a TYPEDEF whose TEXT
// coincides with a $unit-scope CLASS that owns an out-of-body method of the
// same final name.  Surelog's getTaskFunc last fallback scans EVERY file
// content's task_funcs for the LITERAL string, so golden HITS the wrong class
// and keeps the call.
class aliasq32;
  static int wrong32;
  extern static function void dv32(int a);
endclass
function void aliasq32::dv32(int a); wrong32 += a; endfunction

class realq32;
  typedef realq32 aliasq32;   // shadows the $unit class INSIDE realq32
  static int right32;
  extern static function void dv32(int a);
  extern static function void run32();
endclass
function void realq32::dv32(int a); right32 += a; endfunction
function void realq32::run32();
  aliasq32::dv32(7);          // S1 slang -> realq32::dv32 ; Surelog -> literal hit
  realq32::dv32(8);           // S2 CONTROL
endfunction

module vb32r2;
  initial realq32::run32();
endmodule
