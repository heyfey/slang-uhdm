// v125 arm V6 — exotic conversions on the copy-back: real/int, enum, string,
// struct, queue/dynamic element, named-arg binding, defaulted trailing formal.
package Exo_Pkg;
  typedef enum logic [2:0] { E_ZERO, E_ONE, E_TWO } Ecode;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } SPack;

  function automatic int rGrab(output real  rv);  rv = 1.5;  return 0; endfunction
  function automatic int iGrab(output int   iv);  iv = 3;    return 0; endfunction
  function automatic int eGrab(output Ecode ev);  ev = E_ONE; return 0; endfunction
  function automatic int sGrab(output SPack sv);  sv = '0;   return 0; endfunction
  function automatic int strGrab(output string st); st = "x"; return 0; endfunction
  function automatic int twoOut(output logic [63:0] p, output logic [63:0] q);
    p = 0; q = 1; return 0;
  endfunction
  function automatic int defTail(output logic [63:0] p, input int t = 7);
    p = t; return 0;
  endfunction

  class Exo_User;
    int        rc;
    int        iq [$];
    logic [7:0] dyn [];
    real       rHold;
    shortreal  srHold;
    Ecode      eHold;
    logic [1:0] ecodeNarrow;
    SPack      spHold;
    logic [15:0] packedHold;
    string     sHold;
    logic [31:0] lo32, hi32;
    function void run();
      int      ii;
      rc = rGrab(rHold);            // real, matching
      rc = rGrab(srHold);           // shortreal actual against a real formal
      rc = iGrab(ii);               // int, matching
      rc = iGrab(rHold);            // int formal, real actual -> conversion
      rc = eGrab(eHold);            // enum, matching
      rc = eGrab(ecodeNarrow);      // enum formal, 2-bit actual
      rc = sGrab(spHold);           // struct, matching
      rc = sGrab(packedHold);       // struct formal, plain 16-bit actual
      rc = strGrab(sHold);          // string, matching
      rc = twoOut(lo32, hi32);      // TWO converting outputs in one call
      rc = twoOut(.p(lo32), .q(hi32));  // named binding
      rc = defTail(lo32);           // defaulted trailing input
      rc = defTail(.p(lo32), .t(2));
      if (iq.size() > 0) rc = iGrab(iq[0]);   // queue element
      if (dyn.size() > 0) rc = sGrab(dyn[0]); // dynamic-array element
    endfunction
  endclass
endpackage
