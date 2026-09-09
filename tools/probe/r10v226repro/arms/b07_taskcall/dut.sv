// v226 b07 — a process body that reaches the interface's OWN subroutines,
// its typedefs, its parameters and a wildcard-imported package — the four
// roads §218/§220/§221/§223 legislate over, now reached through a PROCESS.
package bp_pkg;
  typedef enum int { BE_A = 0, BE_B = 1 } be_e;
  int pkg_var = 7;
  function automatic int pf(int x); return x + 1; endfunction
endpackage

interface bt_if;
  import bp_pkg::*;
  parameter int PW = 4;
  localparam int LW = PW * 2;
  typedef logic [PW-1:0] w_t;
  w_t   wv;
  int   arr [3];
  be_e  ev;
  int   res;

  task automatic tk(input int x); res = x; endtask
  function automatic int fn(input int x); return x + LW; endfunction

  initial begin
    int loc;
    loc = 0;
    tk(loc);                    // STATEMENT-position user task call
    res = fn(loc);              // EXPRESSION-position user function call
    res = pf(loc);              // package function
    res = pkg_var;              // wildcard-imported package var
    ev  = BE_A;                 // enum constant (§221)
    if (loc) res = LW;          // condition column
    wv  = w_t'(loc);            // cast operand
    foreach (arr[i]) res = arr[i];   // foreach header (§220)
    $display("%0d", loc);       // system-call arg
  end

  always_comb begin
    int loc2;
    loc2 = res;
    if (loc2) wv = '0;
  end
endinterface
